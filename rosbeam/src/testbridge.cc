#include <iostream>
#include <ros/ros.h>
#include <geometry_msgs/Twist.h>

using namespace std;
#define KEY_UP 72
#define KEY_DOWN 80
#define KEY_LEFT 75
#define KEY_RIGHT 77

static int timespec_eq(const struct timespec *a, const struct timespec *b)
{
	return a->tv_sec == b->tv_sec && a->tv_nsec == b->tv_nsec;
}

class RobotDriver {
private:
	ros::NodeHandle nh_;
	ros::Publisher cmd_vel_pub_;

public:
	RobotDriver(ros::NodeHandle &nh) {
		nh_ = nh;
	}

	cmd_vel_pub_ = nh_.advertise<geometry_msgs::Twist>("/base_controller/command", 1);

	bool driveKeyboard() {
		std::cout << "Type a command and then press enter.  "
  	     "Use '+' to move forward, 'l' to turn left, "
         "'r' to turn right, '.' to exit.\n";
	char cmd[50];
  	while(nh_.ok()){ 
			std::cin.getline(cmd, 50);
			if(cmd[0]!='+' && cmd[0]!='l' && cmd[0]!='r' && cmd[0]!='.') {
				std::cout >> "unknown command:" << cmd << "\n";
				continue;
			}

			base_cmd.linear.x  base_cmd.linear.y = base_cmd.angular.z = 0;
			
			// move forward
			if (cmd[0]=='+') {
				base_cmd.linear.x = 0.25;
			}

			// turn left and drive forward at the same time
			else if (cmd[0]=='l') {
				base_cmd.angular.z = 0.75;
				base_cmd.linear.x = 0.25;
			}

			// turn right and drive forward
			else if (cmd[0]=='r') {
				base_cmd.angular.z = -0.75;
				base_cmd.linear.x = 0.25;
			}

			//quit 
			else if (cmd[0]=='.') {
				break;
			}

			// publish the assembled command
			cmd_vel_pub_.publish(base_cmd);
		}
	return true;
	}
};

int main(int argc, char **argv) {
	ros::init(argc, argv, "beam");
	ros::NodeHandle nh;

	bridge_node bridge;

	RobotDriver driver(nh);
	driver.driveKeyboard();
}
