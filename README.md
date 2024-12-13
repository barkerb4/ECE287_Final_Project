# 2-D Platformer Video Game 
ECE287 Final Project for Dr. Jamieson's section B
Authors: Cole Hengstebeck ('22) & Owen Hardy ('22)

Project Description
Our project implements a VGA output which displays a graphic of a helicopter which changes position through a PID algorthim to match the y-position of a shiftable horizontal setpoint.

Background Information
For our project we wanted to implement some sort of control system that would change the physical state of something in the real world. Limited to a Cyclone II board, the closest thing to a physical output we could achieve within the timeline of the project was the VGA output. As per Dr. Jamiesons recommendation, we decided to implement a PID algorthim. We specificially wanted to control the position of a helicopter with a horizontal coordianate setpoint. The user is able to adjust the position of the setpoint using buttons to increase or decrease the y-value. Then, an enable switch turns on the PID algorithm which settles the middle of the helicopter (as indicated with a white dot) with the desired setpoint.

PID Algorithm
Below is a general description of what a PID controller defined by Elproctus.

PID controller consists of three terms, namely proportional, integral and derivative control. The combined operation of these three controllers gives control strategy for process control. PID controller manipulates the process variables like pressure, speed, temperature, flow, etc.

A Feedback signal from the process is compared with a set point or reference signal u(t) and corresponding error signal e(t) which are fed to the PID algorithm. According to the proportional, integral and derivative control calculations in algorithm, the controller produces combined response or controlled output which is applied to control devices.

Design
Below is chronologically listed the order that we created the different parts of our project. References are cited where appropriate.

VGA output
We referenced an excellent example from the blog Time to Explore to initally get our VGA output working. In Will's example, he was using an FPGA with a 100 MHz clock. This meants that we had to scale the 25 MHz VGA clock differently since the Cyclone II runs at 50 MHz. We credit our VGA module to him, that is entirely his work. For our actual "main" Verilog file, we referenced concepts from his tutorial, mainly the definition of box geometry and color. This was actually the easiest part of our project. We initally couldn't get it working because we haddn't assigned the clock object to the internal clock on the FPGA. This was something new to us since we typically used a button-generated clock in lab. Once we got his example tutorial working, we modified it to have a horizontal bar across the screen which would eventually be our horizontal setpoint.

Helicopter graphic
Our helicopter graphic was based off of stock clipart from Google. We chose an image and transferred the outline onto a sheet of graph paper. We then segmented the outline into a series of rectangular boxes based upon the geometry of the helicopter and any segments we wanted to have a different color. We then assigned each box an ID and recorded it's coordinates with (0,0) set in the top left corner of the image. We then transffered these coordinates into Verilog and assigned each box an appropriate color. We ended up having to scale and modify the image from what we orignally had on our graph paper. We discovered that any object that was only 1 pixel in either the x or y dimension was too small and didn't display on the screen. We also decided to change the dimesntions of some of the pieces on the helicopter to make it appear more realistic.

After we created our helicopter graphic, we wanted to change the position using buttons. This was as simple as adding 1 to the y positon of all of the boxes for our "up" button, and vice-versa for "down". We did this on the rising edge of the button click so that you couldn't adjust the setpoint but holding the button down. This would adjust the setpoint at 50 MHz and we didn't want to have a counter for this.

PID algoritm
We referenced Dr. Varodom Toochinda's 2011 publication "Digital PID Controllers" to implement a PID algorithm in Verilog. Although he did give an example in Verilog based off of C code implementation, we had to heavily modify the algorithm for our application.

Tuning
A PID algorithm has 3 constants which need to be tuned to the specific system they are applied in. Ideally, the first output change of a PID controller should be the biggest, and each adjustment thereforth should be smaller than the last, eventually settling on the desired setpoint. Adjusting the Proportional, Integral, and Derivative values requires maintaining a delcate balanced between speed and accuracy. It is not desirable to have a system which adjusts so many times that it's slow, but you also don't want to it to be so quick that your output overshoots the setpoint. This required lots of trial and error. During this stage, the gravity function was added. Flipping the gravity switch simply moves the helicopter down 3 pixels every movement cycle.

Conclusion
We discussed our project design, project goals, and problem-solving methodology for our ECE287 Final Project "PID Helicopter".
