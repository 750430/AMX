PROGRAM_NAME='HoppIP Rev4-00'

(* include the following in your mainline

define_constant //IP Constants

numIPDevices	=	2

ipBiamp			=	1
ipExtron		=	2

define_variable //IP Variables

non_volatile	dev			dvIPClient[]			=	{dvBiamp,dvExtron}
volatile		char		cIPAddresses[][15]		=	{'192.168.1.1','192.168.1.1'}
volatile		integer		nIPPorts[]				=	{23,23}

*)


define_constant

IPReconnectTL	=	3001

define_variable
non_volatile	long		lReconnectTime[]={30000}


define_function openclient(integer nVal)
{
	ip_client_open(dvIPClient[nVal].PORT,cIPAddresses[nVal],nIPPorts[nVal],1)
}

define_function closeclient(integer nVal)
{
	ip_client_close(dvIPClient[nVal].PORT)
}

define_start //IP

for(x=1;x<=numIPDevices;x++) openclient(x)

define_event

data_event[dvIPClient]
{
	online:
	{
		on[nIPConnected[get_last(dvIPClient)]]
	}
	offline:
	{
		off[nIPConnected[get_last(dvIPClient)]]
	}
}

define_start

timeline_create(IPReconnectTL,lReconnectTime,1,timeline_relative,timeline_repeat)

define_event //Timeline Events

timeline_event[IPReconnectTL]
{
	for(x=1;x<=numIPDevices;x++)
	{
		if(!nIPConnected[x])
		{
			closeclient(x)
			openclient(x)
		}
	}
}

