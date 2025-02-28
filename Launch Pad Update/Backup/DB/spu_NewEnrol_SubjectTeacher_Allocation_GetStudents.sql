/****** Object:  StoredProcedure [dbo].[spu_NewEnrol_SubjectTeacher_Allocation_GetStudents]    Script Date: 7/12/2021 3:43:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spu_NewEnrol_SubjectTeacher_Allocation_GetStudents]         
(             
 @batchSize int = 50, @updateFlag int = 0 , @VCEOnly int = 0 
)             
AS        
BEGIN         
SET NOCOUNT ON        
/*        
used to get the list of students to pass to [spu_NewEnrol_SubjectTeacher_Allocation] (which does the update of Teacher)        
        
Functionality: for the current year, work through a @batchSize of students without Teacher in a subject and pass to the        
 other SP which does the calc and update.        
 - @batchSize: number of subjects to work through each time it's run;        
 - @updateFlag: Update if @updateFlag = 1 (default 0 to show only)        
         
Look in view_ClassList for current Enrolment Year and Subjects where the STAFF_ID is set to 'N-A'        
and pass that to the [spu_NewEnrol_SubjectTeacher_Allocation] for allocation.        
        
NOTE: DOES NOT HANDLE 'B' SEMESTERS YET and DOES NOT DO PRIMARY (and may never)        
        
UPDATED: Created 16-Jan-2012|EA| started code        
  16-Jan-2012|EA| after running a few times it failed - as the next Student ID was not being allocated (as no Teachers for that Subject)        
  - added a check to exclude the last retrieved student ID if a problem so they can fall through to the unallocated list.        
  18-Jan-2012|EA| problems with exclusion code meant that it keep switching between 2 problem students and not working.        
   - add a table of student id's to exclude for each batch, and update that as needed.        
   - limit Subject Enrolment Status to ('C','D','E','P') so we don't allocate Subjects that have already been W or otherwise.        
   - AND - over time we might get more errors that remain unfixed than the batch size - so if a problem student then reduce runcount by 1.        
    (as a Student is excluded, not just the Subject, then the number of students updated might be slightly more than the batchsize)        
  23-Jan-2012|EA| BUT - when the numbers get small, and the number of Unallocatable students get large compared to the unallocated students,        
   then the batch could keep going, without finding new students. So cap the number of lookups at 100.        
  1-Feb-2012|EA| based on some nice work by Vikas, the ##tmpTable is Global, #tmpTable is Local, and safest is @tmpTable local variable      
 - So! Change the [##tmpStudentIDExclusions] to a table variable and should be good.      
 DECLARE @people TABLE      
 6-Feb-2012|EA| exclude Home Schooled (Subject Year Level 30 or SubjectID between 980 and 999) as these are not being allocated and 
	gunking up the process. Also change sort order to be Enrolment Date first then student_id to clear earliest enrolments
	And extend @tmpStudentIDExclusions to include SUBJECT_ID as well to limit exclusions
 20-Feb|EA| exclude VET (509) and VCAL (510)
 21-Feb-2012|EA| if a hang then keep the studentid+subject combo so we can ignore specific student/subject combos, without excluding Student and all their subjects.
 13-June-2012|EA| adjust Semester 2 changeover to be June onwards as VCE started Sem 2 from 17 June, per Sharon J/Sue A.
	Also, prioritise VCE subjects (> 500 instead of > 100, for now) and exclude Young Parents (as 'B' Semester just breaks things)
 25-June-2012|EA| change subjects back to > 100 so 7-10 are now allocated.
 15-Jan-2013|EA| add parameter @VCEOnly int = 0 for doing updates to VCE only (1: SubjectID >= 500, otherwise 0:SubjectID>= 100) as will be useful
	for Sem 2 and for start of Sem 1 before everyone else starts.
 22-Jan-2013|EA| for safely, exclude LaunchPad (921,922,923) and Discovery Learning subjects (931,932,933)
 10-Feb-2014|LN| Only students who enrolled more than 1 day ago will get allocated SST and LP/MYVCE. Had to join on STUDENT_ENROLMENT 
                 for the DECV ENROLMENT_DATE rather than the subject ENROLMENT_DATE that the view is bringing back.

10-Dec-2015|EA| change Enrolment year and Semester passed to child proc (spu_NewEnrol_SubjectTeacher_Allocation)
 to switch to Year+1 from 1 Dec 2015 (month =12) and Sem '1' for 2016 enrolments and will go back 
 to 2016 (year) from Jan 2016; 
 Adjustment will be made here also in 2016 to use the Term Dates in DB (unfuddle #484) to check date
 and not run if allocations not done 
10-Feb-2019|EA| temporarily exclude Year 8 per JDL
20-Jan-2020|EA| remove VET 509 as now 905
11 Dec 2020|RW| Exclude year level 8 & 9 which will now be allocated in Timetabler, per John Voglis; SD 27845, 28460, follow-up meeting on 15 Dec
                Removed the concatenated StudentID+SubjectID from the temp exclusion table
                Fixed error in debug output handling of staff allocation: @ENROLMENT_YEAR instead of year(getdate())
16 Jun 2021|RW| Continue allocating full year non-VCE subjects during the mid year period when the S2 non-VCE allocations are still disabled (SD #33335)
-- exec spu_NewEnrol_SubjectTeacher_Allocation_GetStudents 1,0,0
-- Next is Live for student
-- exec spu_NewEnrol_SubjectTeacher_Allocation_GetStudents 65,1,0

*/         
    declare @retval     int        
    SET @retval = 0        
            
 DECLARE @STUDENT_ID int        
 DECLARE @ENROLMENT_YEAR int        
 DECLARE @SubjectID int        
 DECLARE @Semester varchar(1)        
 DECLARE @minSubjectID int    --15-Jan-2013|EA|
       
 --1-2-2012|EA| create a temp table variable      
 DECLARE @tmpStudentIDExclusions TABLE ( STUDENT_ID int, SUBJECT_ID int)      
       
 DECLARE @Prev_STUDENT_ID int  -- stores last student id        
 set @Prev_STUDENT_ID=1        
 DECLARE @RC int      -- returnvalue from spu_NewEnrol_SubjectTeacher_Allocation        
        
 declare @FailCount int    -- stores total fails in a batch - if > @batchSize then jump out of batch        
 set @FailCount = 0        
 --***************************************************Code Modification Starts Here       
 ---Modified By Vikas Baweja       
 --- Modified Date : 01/02/2012      
 ---Error as table already exist in the database in tempdb but not in sys.objects       
 --18-Jan-2012|EA| store excluded students        
 --1-2-2012|EA| remove this      
 /*      
 IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[##tmpStudentIDExclusions]') AND type in (N'U'))         
   begin        
     truncate TABLE [dbo].[##tmpStudentIDExclusions]          
   end        
  else        
   begin          
    create table ##tmpStudentIDExclusions (STUDENT_ID int null)        
   end        
 */      
 ----      
 ----Student showing in Global temporary tables are       
 ---40233, 58949, 62400, 62790, 62851, 62888, 63058, 63124, 63306, 63455, 63460, 63461, 63463, 63465, 63468, 63470, 63471, 63603, 63665, 63693, 63746,      
      
-- IF OBJECT_ID('tempdb..##tmpStudentIDExclusions','local') IS NOT  NULL     
--BEGIN      
--       truncate TABLE [dbo].[##tmpStudentIDExclusions]         
--END      
--ELSE      
--BEGIN      
-- create table ##tmpStudentIDExclusions (STUDENT_ID int null)        
--END      
--***************************************************Code Modification Ends Here       
          
 set @ENROLMENT_YEAR = YEAR(getdate())        
 select @Semester=(case when month(getdate()) > 5 then 2 else 1 end)		-- June2012|EA| alter from June to May

 /*10-Dec-2015|EA| simple override both Enrolment year and Semester passed to child proc
 if we are in Dec instead of making above code more complex 
 - and we can replace with lookup of date in DB as needed (eg: @allocatedate > GETDATE() instead of month(getdate()) = 12 )
 */
 if (month(getdate()) = 12)
	BEGIN
		set @ENROLMENT_YEAR = YEAR(getdate())+1
		set @Semester= 1
	END


--15-Jan-2013|EA| add parameter @VCEOnly int = 0 for doing updates to VCE only (1: SubjectID >= 500, otherwise 0:SubjectID>= 100)
 select @minSubjectID = (case when @VCEOnly = 1 then 500 else 100 end)
 
 -- do an exists and a loop here        
 while (@retval < @batchSize)        
  begin        
   select top 1 @STUDENT_ID=v.STUDENT_ID, @SubjectID=v.SUBJECT_ID     -- LN: 10/2/2014. Added v table.
   from view_Class_List v											-- LN: 10/2/2014. Added v table alias.
   inner join dbo.SUBJECT as sbj on (sbj.SUBJECT_ID = v.SUBJECT_ID)
   LEFT JOIN STUDENT_ENROLMENT se ON v.STUDENT_ID = se.STUDENT_ID	-- LN: 10/2/2014. Join on STUDENT_ENROLMENT table for REAL DECV Enrolment date.
   where v.enrolment_year = @ENROLMENT_YEAR
	and se.ENROLMENT_YEAR = @ENROLMENT_YEAR						--10-Dec-2015|EA| limit to same year otherwise selecting too many wastefully
    --and semester = @Semester        
    and semester  in(convert(varchar(1), @Semester), 'B')		-- 13-June|EA| handle 'B' in Class List so it doesn't break  -- 20-FEB-2020 Changed semseter = (varchar(1), @Semester) to include B 
    and staff_id in ('N-A','NA') -- not yet allocated        
    --15-Jan-2013|EA| changed to handle VCE as parameter
    and ((v.subject_id >= @minSubjectID)   -- 100=non-Primary subjects        -- June|EA| do VCE >=500 for now. (change back to >= 100 for 7-10)
     or ((@Semester = '2') and (v.SEMESTER = 'B') and (v.SUBJECT_ID >= 100))) -- 16 Jun|RW| Continue allocating full year non-VCE subjects during the mid-year period
    and v.SUBJECT_ID < 980	-- 6-Feb-12|EA| exclude Home schooled
	and v.SUBJECT_ID not in (510,353, 905)	-- 20-Feb-12|EA| exclude VET /VCAL / Young Parents. 20-Jan-2020|EA| remove VET 509 as now 905
    and v.SUBJECT_ID not in (921,922,923,924,931,932,933)	--Jan-2013|EA| exclude any LaunchPad or Discovery Learning
    --and semester <> 'B'		-- 13-Jun-2012|EA| exclude 'B' Semester just breaks things) --- HERE
   	--6-Feb-2012|EA| instead of only excluding students by Student ID, also exclude by Subject
	--and STUDENT_ID not in (Select STUDENT_ID from @tmpStudentIDExclusions)       
	--21-Feb-2012|EA| excluding students by Student ID AND Subject
   --16 Dec 2020|RW| Removed the concatenated Student+SubjectID column from the temp exclusion table
   and not exists (select * from @tmpStudentIDExclusions excl where (excl.STUDENT_ID = v.STUDENT_ID) and (excl.SUBJECT_ID = v.SUBJECT_ID))
    and SUBJ_ENROL_STATUS in ('C','D','P')  
	-- 28-June-2018|EA| bunch of subjects that are jamming it up, so ignore for now - REMOVE AFTER 30 JUNE 2018
	-- and v.SUBJECT_ID not in (107,131,216,227,349,350,425,428)
	-- and v.SUBJECT_ID in (211,243,250,216,220)
   -- 11 Dec 2020|RW| Exclude all of year 8 & 9 which will be allocated in Timetabler, per John Voglis
   and (sbj.YEAR_LEVEL not in (8, 9))
    order by v.enrolment_date asc, v.STUDENT_ID asc --,  SUBJECT_ID desc       -- LN: 10/2/2014. Added v table.
    
    --6-Feb-2012|EA| instead of only excluding students by Student ID, also exclude by Subject
    set @retval = @retval + 1
	
   
   --debug        
   --print @student_ID        
   --print @subjectID        

   -- update to Teacher spu_NewEnrol_SubjectTeacher_Allocation        
   if (@STUDENT_ID is not null AND @SubjectID is not null)        
    begin        
     exec @RC= spu_NewEnrol_SubjectTeacher_Allocation  @STUDENT_ID , @ENROLMENT_YEAR , @SubjectID , @Semester , @updateFlag        
                    
     IF @@ERROR <> 0        
     BEGIN        
      PRINT 'Update to Student-Subject Failed. CODE: '+LTRIM(STR(@@ERROR));        
     END        
     --16-Jan-2012|EA|set to previous Student to exclude for this batch.        
     if (@RC<0)         
      begin        
       --set @Prev_STUDENT_ID = @STUDENT_ID        
       insert into @tmpStudentIDExclusions(STUDENT_ID, SUBJECT_ID) values(@STUDENT_ID, @SubjectID)
       set @retval = @retval - 1        
       set @FailCount = @FailCount + 1        
       --print @FailCount        
       if (@FailCount > @batchSize) set @retval = @retval + 1        
      end        
             
    end        
            
    end        
             
    if (@updateFlag=0) 
	begin
		select 
			t.STUDENT_ID, 
			t.SUBJECT_ID, 
			su.SUBJECT_ABBREV,
			su.SUBJECT_TITLE,
			su.DEFAULT_SEMESTER,
			su.YEAR_LEVEL,
			(SELECT STAFF_ID FROM STUDENT_SUBJECT WHERE STUDENT_ID = t.STUDENT_ID AND SUBJECT_ID = t.SUBJECT_ID AND ENROLMENT_YEAR = @ENROLMENT_YEAR) AS Allocated
		from @tmpStudentIDExclusions t 
		left join subject su on su.SUBJECT_ID = t.SUBJECT_ID
		order by su.SUBJECT_ABBREV
	end 
        
end     