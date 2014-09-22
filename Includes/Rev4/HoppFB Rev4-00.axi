PROGRAM_NAME='HoppFB Rev4-00'
(***********************************************************)
(*  FILE CREATED ON: 09/15/2008  AT: 08:04:09              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/15/2008  AT: 08:10:06        *)
(***********************************************************)

//You must define a function tp_fb() in your define_function section or this won't compile
//Any events you might have previously put in define_program, you now put in tp_fb()


define_constant

FeedbackTL	=	3000

define_variable
volatile		integer		nSkipFeedback
non_volatile	long		lFeedbackTime[]={100}

define_start

timeline_create(FeedbackTL,lFeedbackTime,1,timeline_relative,timeline_repeat)

define_event //Timeline Events

timeline_event[FeedbackTL]
{
	if (!nSkipFeedback) tp_fb()
}