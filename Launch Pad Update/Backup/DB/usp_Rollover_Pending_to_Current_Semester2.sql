/****** Object:  StoredProcedure [dbo].[usp_Rollover_Pending_to_Current_Semester2]    Script Date: 7/12/2021 4:22:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_Rollover_Pending_to_Current_Semester2]
( @VCEOnly int = 1 )
As
Begin
/*
 13-June-2013|EA| adjust Enrolment year to use current year
	NOTE: This is only for VCE (500+ subjects) and will need to change for 1-500 subjects (F-6 & 7-10)
 27-June-2013|EA| adjust to nonVCE (subject ID < 500 and >= 900)(F-6 & 7-10)
  16-Jul-2017|EA| run for F-10, but also added check for WD is null 
  26-June-2018|EA| if the student is Extending, then they linked sem 2 subject should remain P not C (!!!!! TO DO !!!!)
  10-June-2019|EA| the E->P thing is handled in SQL Agent job. Also add  @VCEOnly int = 0 to simplify running it instead of
	editing the code every semester changover.
  09-Aug-2019|EA| add 'B' for P to C per feedback  
  11 Jun 2021|RW| Minor adjustments to more easily switch between VCE-only and all subjects; also, exclude test students
  5 Jul 2021|RW| Changed minimum subject from 100, to 1. Primary subjects should only be temporarily excluded at the start of the year..?
*/ 

set nocount on

DECLARE @minSubjectID int    -- 10-June-2019|EA| minimun subject id
select @minSubjectID = (case when @VCEOnly = 1 then 500 else 1 end)

BEGIN TRY
	BEGIN TRAN
		UPDATE ss SET ss.SUBJ_ENROL_STATUS = 'C'
		-- select top 10 *
		FROM Student_subject ss 
		INNER JOIN STUDENT_ENROLMENT sen ON ss.STUDENT_ID = sen.STUDENT_ID AND ss.ENROLMENT_YEAR = sen.ENROLMENT_YEAR
		WHERE sen.ENROLMENT_YEAR = YEAR(getdate())
		AND sen.ENROLMENT_STATUS = 'E'
		AND ss.SUBJ_ENROL_STATUS = 'P'
		and (ss.semester='2' or ss.semester='B')
		and ss.WITHDRAWAL_DATE is null
      and
      (
         (ss.SUBJECT_ID between @minSubjectID and 899)
         or (ss.SUBJECT_ID = 924) -- VCE-O
         or (ss.SUBJECT_ID in (921, 922, 923)) -- Non-VCE LP
      )
		
      -- Exclude test students for now. Yuck.
      and (sen.STUDENT_ID not in (56794, 66235, 66236, 66237, 100849, 100855, 100857, 103001, 103002, 103003, 103004, 103005, 103006))

	COMMIT TRAN
PRINT 'job successful'
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	RAISERROR ('Error occured job failed',10,1,@@error)
END CATCH
End
