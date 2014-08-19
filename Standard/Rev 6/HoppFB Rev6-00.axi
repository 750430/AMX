PROGRAM_NAME='HoppFB Rev6-00'

define_constant

tlFeedback		=	3000

define_variable //Feedback Variables

non_volatile	long		lFeedbackTime[]={300}

define_start

timeline_create(tlFeedback,lFeedbackTime,1,timeline_relative,timeline_repeat)

define_event

timeline_event[tlFeedback]
{
	tp_fb()
}