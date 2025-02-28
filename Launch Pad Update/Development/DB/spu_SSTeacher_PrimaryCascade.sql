SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spu_SSTeacher_PrimaryCascade]   
(       
 @updateFlag int   
)       
AS  
BEGIN   
SET NOCOUNT ON  
/*  
 
Functionality: cascade the SST for a Primary student to other Primary Subjects, including LP1 and DL1
	 to keep them in sync;
	(Note: for new enrolments to simplify the manual selection of the SST (that primary wish to continue)
		the '[spi_ins_PrimarySubjects_multiple]' will add the LP1 and DL1 subjects if yearlevels 3-6, if not existing)
	
	Do Update if @updateFlag = 1 (default 0 to show only)  
	Uses the current year as @EnrolmentYear  

UPDATED: Created 17-Dec-2014|EA| started code  
	29 Jan 2015|EA|Minor updates to use current enrolment year only
	16-Feb-2016|EA| allow changes to LP1/2/3 instead of Lp1 (see 84646 Yr6 doing Yr7 & LP2)
	31-Jan-2017|LN| Discovery Learning is no longer a mandatory subject.
   13 Feb 2021|RW| Added safeguard to exclude NO_SST Learning Advisors; rare but possible for primary students
    9 Dec 2021|RW| Updated reference to LP/introductory subjects to use the view instead of hardcoding subject IDs
*/   
  
	declare @retval     int        
    SET @retval = 0        
	declare @ENROLMENT_YEAR INT
	set @ENROLMENT_YEAR = YEAR(GETDATE())
       
    /* update the Primary subjects if the ss teacher is not NA and different from subjects */
	if (@updateFlag = 1)
		begin
		update SS 
		set ss.staff_id = se.pastoral_care_id
			, ss.LAST_ALTERED_BY = 'AutoFix', ss.LAST_ALTERED_DATE = getdate()
		--select se.student_id, se.PASTORAL_CARE_ID, se.YEAR_LEVEL, se.ENROLMENT_YEAR,ss.SUBJECT_ID, ss.SUBJ_ENROL_STATUS, ss.STAFF_ID 
			from student_enrolment se, student_subject ss
		where se.student_id = ss.student_id
			and se.enrolment_year = ss.enrolment_year
			and se.enrolment_year = @ENROLMENT_YEAR
			and se.enrolment_status = 'E'							-- Enrolled
			and se.year_level between 0 and 6		-- Primary only
			and ss.subj_enrol_status in ('C','D','E','P')
			and se.pastoral_care_id not in ('N-A','NA', 'NO_SST')  -- don't cascade NA's or NO_SSTs
			and se.pastoral_care_id <> ss.staff_id		-- where SSTeacher differs from LP/DL Staff ID 
			and (
				--ss.SUBJECT_ID in (921,922,923, 931,932,933)		-- LP and DL (added LP2/3 DL2/3 16 Feb-2016|EA|)
				ss.SUBJECT_ID in (select vis.IntroductorySubjectID from dbo.vwIntroductorySubject as vis where (vis.IntroductorySubjectStatus = 1))
				or ss.subject_id in (select distinct subject_id from subject where sub_school = 'P-6' and status=1)
				)

		IF @@ERROR <> 0        
		 BEGIN        
			  PRINT 'Update to Student-SS Teacher Failed. CODE: '+LTRIM(STR(@@ERROR));        
		 END        
			 set @retval = -1        
	end
	else
	begin
		-- not update so just show list
		select se.student_id, se.PASTORAL_CARE_ID, se.YEAR_LEVEL, se.ENROLMENT_YEAR,ss.SUBJECT_ID, ss.SUBJ_ENROL_STATUS, ss.STAFF_ID 
			from student_enrolment se, student_subject ss
		where se.student_id = ss.student_id
			and se.enrolment_year = ss.enrolment_year
			and se.enrolment_year = @ENROLMENT_YEAR
			and se.enrolment_status = 'E'							-- Enrolled
			and se.year_level between 0 and 6		-- Primary only
			and ss.subj_enrol_status in ('C','D','E','P')
			and se.pastoral_care_id not in ('N-A','NA', 'NO_SST')  -- don't cascade NA's or NO_SSTs
			and se.pastoral_care_id <> ss.staff_id		-- where SSTeacher differs from LP/DL Staff ID 
			and (ss.SUBJECT_ID in (select vis.IntroductorySubjectID from dbo.vwIntroductorySubject as vis where (vis.IntroductorySubjectStatus = 1))
				or ss.subject_id in (select distinct subject_id from subject where sub_school = 'P-6' and status=1)
				)
	end

	return @retval
	
end  
 
