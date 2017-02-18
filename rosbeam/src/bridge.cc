#include <ros/ros.h>
#include <nav_msgs/Odometry.h>
#include <geometry_msgs/Twist.h>
#include <std_msgs/Empty.h>
#include <tf2_msgs/TFMessage.h>

#include <boost/thread.hpp>

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <pthread.h>
#include <string.h>
#include <errno.h>

#include "drive_command.h"

static int timespec_eq(const struct timespec *a, const struct timespec *b)
{
	return a->tv_sec == b->tv_sec && a->tv_nsec == b->tv_nsec;
}

class bridge_node {
private:
	ros::NodeHandle node;
	ros::Publisher pubOdom, pubTf;
	ros::Subscriber subVel, subEmpty;

	boost::thread odomThread;

	struct drive_shm *shm;

	bool first_time;
	struct timespec stat_time;
	struct drive_status stat;

	double x;
	double y;
	double theta;
	double last_lin_enc, last_ang_enc;
	bool first_enc;
public:
	bool start() {
		int fd = shm_open(DRIVE_SHM_NAME, O_RDWR, 0);
		if (fd < 0) {
			ROS_ERROR("shm_open: %s", strerror(errno));
			return false;
		}

		shm = (struct drive_shm *)mmap(NULL, sizeof(*shm), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
		if (close(fd) < 0)
			ROS_WARN("close: %s", strerror(errno));

		if (shm == MAP_FAILED) {
			ROS_ERROR("mmap: %s", strerror(errno));
			return false;
		}

		subVel = node.subscribe("cmd_vel", 2, &bridge_node::sub_vel, this);
		// subEmpty = node.subscribe("publish_odom", 2, &bridge_node::sub_empty, this);

		pubOdom = node.advertise<nav_msgs::Odometry>("odom", 50);
		pubTf = node.advertise<tf2_msgs::TFMessage>("/tf", 100);

		x = 0.0;
		y = 0.0;
		theta = 0.0;
		first_enc = true;

		odomThread = boost::thread(&bridge_node::process_odometry, this);

		return true;
	}

	void publish_odometry() {
		pthread_mutex_lock(&shm->stat_lock);
		if (first_time) {
			first_time = false;
			stat_time = shm->stat_time;
		}
		while (timespec_eq(&stat_time, &shm->stat_time)) {
			pthread_cond_wait(&shm->stat_cond, &shm->stat_lock);
		}
		stat_time = shm->stat_time;
		stat = shm->stat;
		pthread_mutex_unlock(&shm->stat_lock);

		ROS_INFO("Publishing Odometry");
		ros::Time time = ros::Time::now();

		double lin_enc = (stat.encoder_1 - stat.encoder_2) * 0.0040578907f;
		double ang_enc = (stat.encoder_2 + stat.encoder_1) * -0.019415744f;
		double lin_vel = stat.actualLinearVelocity / 65536.0;
		double ang_vel = stat.actualAngularVelocity / 65536.0;

		if (first_enc) {
			first_enc = false;
			last_lin_enc = lin_enc;
			last_ang_enc = ang_enc;
			return;
		}

		double movement = lin_enc - last_lin_enc;
		double rotation = ang_enc - last_ang_enc;
		last_lin_enc = lin_enc;
		last_ang_enc = ang_enc;

		// add calibration factors
		double lin_calib = 0.84;
		double ang_calib = 1.0;
		double movement_calib = movement * lin_calib;
		double rotation_calib = rotation * ang_calib;

		x += cos(theta + rotation_calib/2) * movement_calib;
		y += sin(theta + rotation_calib/2) * movement_calib;
		theta += rotation_calib;

		nav_msgs::Odometry odom;
		odom.header.stamp = time;
		odom.header.frame_id = "odom";
		odom.child_frame_id = "base_link";

		odom.pose.pose.position.x = x;
		odom.pose.pose.position.y = y;
		odom.pose.pose.orientation.z = sin(theta/2);
		odom.pose.pose.orientation.w = cos(theta/2);

		odom.twist.twist.linear.x = lin_vel;
		odom.twist.twist.angular.z = ang_vel;

		odom.twist.twist.linear.z = movement;
		odom.twist.twist.angular.x = rotation;

		pubOdom.publish(odom);

		geometry_msgs::TransformStamped trans;
		trans.header.stamp = odom.header.stamp;
		trans.header.frame_id = odom.header.frame_id;
		trans.child_frame_id = odom.child_frame_id;

		trans.transform.translation.x = odom.pose.pose.position.x;
		trans.transform.translation.y = odom.pose.pose.position.y;
		trans.transform.translation.z = odom.pose.pose.position.z;
		trans.transform.rotation = odom.pose.pose.orientation;

		tf2_msgs::TFMessage tf2msg;
		tf2msg.transforms.push_back(trans);
		pubTf.publish(tf2msg);
	}

	void process_odometry() {
		// ros::Rate r(10);
		while (ros::ok()) {
			// ROS_INFO("Publishing odom every %.3f seconds.", r.cycleTime().toSec());
			publish_odometry();
			// r.sleep();
		}
	}

	void join() {
		odomThread.join();
	}

	// void sub_empty(std_msgs::Empty msg) {
	// 	// ROS_INFO("Got publish odom request.");
	// 	publish_odometry();
	// }

	void sub_vel(const geometry_msgs::Twist::ConstPtr& msg) {
		double lin_vel = msg->linear.x;
		double ang_vel = msg->angular.z;

		if (lin_vel > 0.5 || ang_vel > 0.5) {
			ROS_WARN("velocity too large, lin:%f ang:%f", lin_vel, ang_vel);
			return;
		}

		struct drive_command cmd = {DRIVE_COMMAND_MAGIC, 1,
			lin_vel*65536, ang_vel*65536, 0, -1, -1};
		struct timespec now;
		clock_gettime(CLOCK_MONOTONIC, &now);

		now.tv_nsec += 150000000;
		if (now.tv_nsec >= 1000000000) {
			now.tv_sec++;
			now.tv_nsec -= 1000000000;
		}

		pthread_mutex_lock(&shm->cmd_lock);
		shm->cmd_time = now;
		shm->cmd = cmd;
		pthread_mutex_unlock(&shm->cmd_lock);
	}
};

int main(int argc, char **argv) {
	ros::init(argc, argv, "beam");

	bridge_node bridge;

	if (!bridge.start())
		return 1;

	ROS_INFO("start");
	ros::spin();

	bridge.join();

	return 0;
}
