PROGRAM_NAME='HoppSERVER Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'HoppSERVER Rev6-00'

*)
define_device

dvIPServer		=	00000:11:0

define_variable


define_start 

ip_server_open(dvIPServer.port,1320,IP_TCP)

define_event

data_event[dvIPServer]
{
	online:
	{
		send_string data.device,"'Welcome to the Hoppmann AMX Server'"
	}
	offline:
	{
		ip_server_close(dvIPServer.port)
		ip_server_open(dvIPServer.port,1320,IP_TCP)
	}
}

define_program

wait 200 send_string dvIPServer,"'Still Connected to the Hoppmann AMX Server'"