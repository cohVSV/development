/****** Object:  StoredProcedure [dbo].[spi_ins_PrimarySubjects_multiple]    Script Date: 7/12/2021 3:44:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[spi_ins_PrimarySubjects_multiple]
(
	@StudentID integer = null
	,@EnrolmentYear integer = null
	,@YEARLEVEL_SubjectID integer = 0
	,@YEARLEVEL_Distribution char(1) = 'B'
	,@YEARLEVEL_EnrolDate date = null
	,@Sem1Eng_SubjectID integer = 0
	,@Sem1Eng_Distribution char(1) = 'B'
	,@Sem1Eng_EnrolDate date = null
	,@Sem1Math_SubjectID integer = 0
	,@Sem1Math_Distribution char(1) = 'B'
	,@Sem1Math_EnrolDate date = null
	,@Sem2Eng_SubjectID integer = 0
	,@Sem2Eng_Distribution char(1) = 'B'
	,@Sem2Eng_EnrolDate date = null
	,@Sem2Math_SubjectID integer = 0
	,@Sem2Math_Distribution char(1) = 'B'
	,@Sem2Math_EnrolDate date = null
	,@UserID varchar(8) = 'unknown'
)
AS
/*
Created by:			Eric Affleck  2010-Sept-20
Functionality:		receives up to 5 Primary Subjects (1 Year based, and up to 4 Unit based) 
					and inserts to STUDENT_SUBJECT table. Reduces need to insert each subject 
					individually. Will ignore if a subject already in STUDENT_SUBJECT.
							
Status:				development

Updated:			20-Sept-2010|EA| creation
					receive Student ID, Enrolment Year, and subject codes for English + Maths, 
						for Semester 1 + 2. Defaults of 'B'ook distribution and Today for Enrol date, 
					and assume 0 subject. If Subject = 0 or already EXISTS for student and Enrol year
						then won't INSERT
					22-Sept-2010|EA| updated for BOOK_DESPATCH inserts of subjects
					02-Dec-2010|EA| update for certain Unit 10-18 Primary subjects to start at book 10 (unfuddle #344)
					- this reflects code added to form 'Student_Subject_maintain' for adding individual subjects
					16-Dec-2010|EA| minor changes to Unit 10-18 Primary subjects book adding due to changes found 
						when testing, to do with maximum book should be 18 not 19.
					21/27-Nov-2014|EA| changed the @MAX_BOOKS to lookup from SUBJECTS and then for the I-P (usually 2nd semester subjects)
					to bump them up by @MAX_BOOKS
					17-Dec-2014|EA| for Years 3-6 then add in LP1 (921) and DL1 (931)
					2-June-2017|EA| per service desk #6723 Diane M. remove DL1 enrolments for Primary as no longer needed.
					29-May-2019|EA| for Year 6, change to LP1 (ie 3-5 LP1, 6-8 LP2) per 2019 request (#817, sd #18445)
					26-Nov-2019|EA| change 'NA' to 'N-A' per cleanup (sd #21024)
               11 Dec 2021|RW| Updated reference to LP/introductory subject to use the view instead of hardcoding subject IDs
                               Changed logic for initial subject enrolment status for semester '1' and 'B' subjects; used spi_AddStudentSubject as a reference.
*/
BEGIN
set nocount on

declare @semester1EnrolmentStatus char(1) = iif((@EnrolmentYear > year(getdate())) or (datepart(DAYOFYEAR, getdate()) < 28), 'P', 'C');

declare @strSem2_enrol_status char(1)
set @strSem2_enrol_status = 'P'	-- most of the time


-- if no student ID then return 
if (@StudentID is null)
	begin
		return -1	-- not enough details
	end
else
	-- start a transaction and do a check on each insert     
	BEGIN    
		BEGIN TRAN   
		BEGIN TRY  
			if(@EnrolmentYear is null) set @EnrolmentYear = YEAR(getdate())
		
			/* change enrol status for Semester 2 subjects based on month enrolment takes place
			 1 or B - always 'C'urrent; 2 - if July-Oct then 'C' otherwise likely 'P'ending
			*/
			if (MONTH(getdate()) between 7 and 10) set @strSem2_enrol_status = 'C'
		
			-- START Year Level Subject insert
			IF ((@YEARLEVEL_SubjectID > 0) and not exists(select subject_id from STUDENT_SUBJECT where SUBJECT_ID=@YEARLEVEL_SubjectID and ENROLMENT_YEAR=@EnrolmentYear and STUDENT_ID=@StudentID))
				begin
					-- main subject
					INSERT STUDENT_SUBJECT(STUDENT_ID, ENROLMENT_YEAR, SUBJECT_ID,STAFF_ID, SEMESTER
						, ENROLMENT_DATE, SUBJ_ENROL_STATUS, VBOS_REGISTERED,APPEARS_ON_VASS, NUM_ASSMT_SUBMISSIONS, EXTENSION_OF_VCE_UNIT, COURSE_DISTRIBUTION
						,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@YEARLEVEL_SubjectID, 'N-A', 'B'
						,@YEARLEVEL_EnrolDate, @semester1EnrolmentStatus ,1,0,0,0,@YEARLEVEL_Distribution
						,@UserID, GETDATE())
						
					-- ignore SUBJECT.DEFAULT_TEACHER_ID update as hardly used
						
					-- STUD_SUBJ_FINAL
					INSERT STUD_SUBJ_FINAL (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@YEARLEVEL_SubjectID,@UserID, GETDATE())
					-- STUD_SUB_INTERIM
					INSERT STUD_SUB_INTERIM (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@YEARLEVEL_SubjectID,@UserID, GETDATE())
			
				end		--@YEARLEVEL_SubjectID > 0 
			
			-- START @Sem1Eng_SubjectID insert
			IF ((@Sem1Eng_SubjectID > 0) and not exists(select subject_id from STUDENT_SUBJECT where SUBJECT_ID=@Sem1Eng_SubjectID and ENROLMENT_YEAR=@EnrolmentYear and STUDENT_ID=@StudentID))
				begin
					-- main subject
					INSERT STUDENT_SUBJECT(STUDENT_ID, ENROLMENT_YEAR, SUBJECT_ID,STAFF_ID, SEMESTER
						, ENROLMENT_DATE, SUBJ_ENROL_STATUS, VBOS_REGISTERED,APPEARS_ON_VASS, NUM_ASSMT_SUBMISSIONS, EXTENSION_OF_VCE_UNIT, COURSE_DISTRIBUTION
						,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem1Eng_SubjectID, 'N-A', '1'
						,@Sem1Eng_EnrolDate, @semester1EnrolmentStatus ,1,0,0,0,@Sem1Eng_Distribution
						,@UserID, GETDATE())
						
					-- ignore SUBJECT.DEFAULT_TEACHER_ID update as hardly used
						
					-- STUD_SUBJ_FINAL
					INSERT STUD_SUBJ_FINAL (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem1Eng_SubjectID,@UserID, GETDATE())
					-- STUD_SUB_INTERIM
					INSERT STUD_SUB_INTERIM (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem1Eng_SubjectID,@UserID, GETDATE())
			
				end 

		
			-- START @Sem2Eng_SubjectID insert, with special enrol status
			IF ((@Sem2Eng_SubjectID > 0) and not exists(select subject_id from STUDENT_SUBJECT where SUBJECT_ID=@Sem2Eng_SubjectID and ENROLMENT_YEAR=@EnrolmentYear and STUDENT_ID=@StudentID))
				begin
					-- main subject
					INSERT STUDENT_SUBJECT(STUDENT_ID, ENROLMENT_YEAR, SUBJECT_ID,STAFF_ID, SEMESTER
						, ENROLMENT_DATE, SUBJ_ENROL_STATUS, VBOS_REGISTERED,APPEARS_ON_VASS, NUM_ASSMT_SUBMISSIONS, EXTENSION_OF_VCE_UNIT, COURSE_DISTRIBUTION
						,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem2Eng_SubjectID, 'N-A', '2'
						,@Sem2Eng_EnrolDate, @strSem2_enrol_status ,1,0,0,0,@Sem2Eng_Distribution
						,@UserID, GETDATE())
						
					-- ignore SUBJECT.DEFAULT_TEACHER_ID update as hardly used
						
					-- STUD_SUBJ_FINAL
					INSERT STUD_SUBJ_FINAL (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem2Eng_SubjectID,@UserID, GETDATE())
					-- STUD_SUB_INTERIM
					INSERT STUD_SUB_INTERIM (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem2Eng_SubjectID,@UserID, GETDATE())
			
				end 
						
			-- START @Sem1Math_SubjectID insert
			IF ((@Sem1Math_SubjectID > 0) and not exists(select subject_id from STUDENT_SUBJECT where SUBJECT_ID=@Sem1Math_SubjectID and ENROLMENT_YEAR=@EnrolmentYear and STUDENT_ID=@StudentID))
				begin
					-- main subject
					INSERT STUDENT_SUBJECT(STUDENT_ID, ENROLMENT_YEAR, SUBJECT_ID,STAFF_ID, SEMESTER
						, ENROLMENT_DATE, SUBJ_ENROL_STATUS, VBOS_REGISTERED,APPEARS_ON_VASS, NUM_ASSMT_SUBMISSIONS, EXTENSION_OF_VCE_UNIT, COURSE_DISTRIBUTION
						,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem1Math_SubjectID, 'N-A', '1'
						,@Sem1Math_EnrolDate, @semester1EnrolmentStatus ,1,0,0,0, @Sem1Math_Distribution
						,@UserID, GETDATE())
						
					-- ignore SUBJECT.DEFAULT_TEACHER_ID update as hardly used
						
					-- STUD_SUBJ_FINAL
					INSERT STUD_SUBJ_FINAL (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem1Math_SubjectID,@UserID, GETDATE())
					-- STUD_SUB_INTERIM
					INSERT STUD_SUB_INTERIM (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem1Math_SubjectID,@UserID, GETDATE())
			
				end 

		
			-- START @Sem2Math_SubjectID insert, with special enrol status
			IF ((@Sem2Math_SubjectID > 0) and not exists(select subject_id from STUDENT_SUBJECT where SUBJECT_ID=@Sem2Math_SubjectID and ENROLMENT_YEAR=@EnrolmentYear and STUDENT_ID=@StudentID))
				begin
					-- main subject
					INSERT STUDENT_SUBJECT(STUDENT_ID, ENROLMENT_YEAR, SUBJECT_ID,STAFF_ID, SEMESTER
						, ENROLMENT_DATE, SUBJ_ENROL_STATUS, VBOS_REGISTERED,APPEARS_ON_VASS, NUM_ASSMT_SUBMISSIONS, EXTENSION_OF_VCE_UNIT, COURSE_DISTRIBUTION
						,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem2Math_SubjectID, 'N-A', '2'
						,@Sem2Math_EnrolDate, @strSem2_enrol_status ,1,0,0,0,@Sem2Math_Distribution
						,@UserID, GETDATE())
						
					-- ignore SUBJECT.DEFAULT_TEACHER_ID update as hardly used
						
					-- STUD_SUBJ_FINAL
					INSERT STUD_SUBJ_FINAL (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem2Math_SubjectID,@UserID, GETDATE())
					-- STUD_SUB_INTERIM
					INSERT STUD_SUB_INTERIM (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
					VALUES(@StudentID , @EnrolmentYear ,@Sem2Math_SubjectID,@UserID, GETDATE())
			
				end 
						
			
			-- do insert to BOOK_DESPATCH as a bulk lot for all subjects, where needed
			-- can collect only those subjects enrolled (above) from STUDENT_SUBJECT and insert 1-5 in loop, WHILE/WEND
			declare @bookCounter integer
			set @bookCounter = 1	-- start at book 0, per Stephen Hill, and use 18 books for all for 2011, may lower later to 9

			-- 02-Dec-2010|EA| start counting at 10 for Units 10-18 in Primary (unfuddle #344)
			declare @intMAX_BOOKS integer
			set @intMAX_BOOKS = 8
			if 	(@Sem1Eng_SubjectID in (2,12,22,3,13,23) or @Sem1Math_SubjectID in (4,16,23,5,17,27) or @Sem2Eng_SubjectID in (2,12,22,3,13,23) or @Sem2Math_SubjectID in (4,16,23,5,17,27))
			begin
				-- F-2 subjects
					set @intMAX_BOOKS = 9
			end			
			
			while @bookCounter <= @intMAX_BOOKS
				begin
					insert BOOK_DESPATCH (STUDENT_ID, ENROLMENT_YEAR, SUBJECT_ID, BOOK_ID, DESPATCH_STATUS, LAST_ALTERED_BY, LAST_ALTERED_DATE)
					select @StudentID, @EnrolmentYear, Subject_ID, @bookCounter, 'T', @UserID, GETDATE()
						from STUDENT_SUBJECT
						where STUDENT_ID =  @StudentID and ENROLMENT_YEAR = @EnrolmentYear
							and SUBJECT_ID in (@Sem1Eng_SubjectID ,@Sem1Math_SubjectID ,@Sem2Eng_SubjectID ,@Sem2Math_SubjectID)
							-- and remove possible duplicates, if they already exist in BOOK_DESPATCH
							and SUBJECT_ID not in (select SUBJECT_ID from BOOK_DESPATCH 
													where STUDENT_ID =  @StudentID and ENROLMENT_YEAR = @EnrolmentYear and BOOK_ID = @bookCounter
														and SUBJECT_ID in (@Sem1Eng_SubjectID ,@Sem1Math_SubjectID ,@Sem2Eng_SubjectID ,@Sem2Math_SubjectID)
												)
					set @bookCounter = @bookCounter + 1
				end
				--print 'DEBUG: inserted all books BOOK_DESPATCH'
				-- 02-Dec-2010|EA| put in a single Year level book, ID 1
					insert BOOK_DESPATCH (STUDENT_ID, ENROLMENT_YEAR, SUBJECT_ID, BOOK_ID, DESPATCH_STATUS, LAST_ALTERED_BY, LAST_ALTERED_DATE)
					select @StudentID, @EnrolmentYear, @YEARLEVEL_SubjectID, 1, 'T', @UserID, GETDATE()
						from STUDENT_SUBJECT
						where STUDENT_ID =  @StudentID and ENROLMENT_YEAR = @EnrolmentYear
							and SUBJECT_ID =  @YEARLEVEL_SubjectID
							-- and remove possible duplicates, if they already exist in BOOK_DESPATCH
							and SUBJECT_ID not in (select SUBJECT_ID from BOOK_DESPATCH 
													where STUDENT_ID =  @StudentID and ENROLMENT_YEAR = @EnrolmentYear and BOOK_ID = 1
														and SUBJECT_ID = @YEARLEVEL_SubjectID
													)
				
				-- 16-Dec-2010|EA| now bump up the Books for Units 10-18 in F-2 Primary (unfuddle #344)
				-- 28-Nov-2014|EA| list updated for 2015 subjects with J-R modules
				update BOOK_DESPATCH
					set BOOK_ID = (BOOK_ID+@intMAX_BOOKS)
					where STUDENT_ID =  @StudentID and ENROLMENT_YEAR = @EnrolmentYear
						and SUBJECT_ID in (@Sem1Eng_SubjectID ,@Sem1Math_SubjectID ,@Sem2Eng_SubjectID ,@Sem2Math_SubjectID) 
						and SUBJECT_ID in (3,5,13,17,23,27,34,37,45,47,53,56,62,66, 32,42,48,146,141,155,157,159,151,163,167,160)
						and (BOOK_ID > 0 and BOOK_ID < @intMAX_BOOKS+1)
			
			/* 17-Dec-2014|EA| also add in the LP & DL if they don't exist to save extra work for Year 3-6 
			29-May-2019|EA| for Year 6, change to LP2 (ie 3-5 LP1, 6-8 LP2) per 2019 request
         11 Dec 2021|RW| Use the new LP view to determine the correct chronological year level LP subject to create for the student, if any
			*/
			if exists (SELECT YEAR_LEVEL FROM STUDENT_ENROLMENT WHERE YEAR_LEVEL BETWEEN 3 and 6 AND STUDENT_ID=@StudentID  AND ENROLMENT_YEAR=@EnrolmentYear )
				begin

               -- Dec 11 2021|RW| Fetch the matching chronological year level LP subject for the student
               declare @lpSubjectToCreate int
                  =
                       (
                          select top 1
                             vis.IntroductorySubjectID
                           from
                             dbo.STUDENT_ENROLMENT as se
                             inner join dbo.vwIntroductorySubject as vis
                                on (
                                      (vis.IntroductorySubjectYearLevel = se.YEAR_LEVEL)
                                      and (vis.IntroductorySubjectStatus = 1)
                                   )
                           where
                             (se.STUDENT_ID = @StudentID)
                             and (se.ENROLMENT_YEAR = @EnrolmentYear)
                       );

               -- Create the subject if we have a candidate LP subject ID for the student's year level,
               -- and if NO year 3 - 10 LP for the student has already been created
               if (
                     (@lpSubjectToCreate is not null)
                     and (not exists
                           (
                              select
                                 *
                               from
                                 dbo.STUDENT_SUBJECT as ss
                               where
                                 (ss.STUDENT_ID = @StudentID)
                                 and (ss.ENROLMENT_YEAR = @EnrolmentYear)
                                 and (ss.SUBJECT_ID in
                                      (
                                         select
                                            vis.IntroductorySubjectID
                                          from
                                            dbo.vwIntroductorySubject as vis
                                          where
                                            (vis.IntroductorySubjectStatus = 1)
                                            and (vis.IntroductorySubjectYearLevel between 3 and 10)
                                      )
                                     )
                           )
                         )
                  )
					begin  
						print 'Adding LP'  

						INSERT INTO STUDENT_SUBJECT  (student_id, enrolment_year, subject_id, staff_id, semester, enrolment_date, subj_enrol_status
							, VBOS_REGISTERED, APPEARS_ON_VASS, NUM_ASSMT_SUBMISSIONS, EXTENSION_OF_VCE_UNIT, course_distribution
							, LAST_ALTERED_BY, LAST_ALTERED_DATE)
						select @StudentID, @EnrolmentYear,  @lpSubjectToCreate, 'N-A', 'B', GETDATE(), @semester1EnrolmentStatus
						, 1,0,0,0,'I'
						,'AutoJob', GETDATE()
			 
						-- ADD The Interim and Final Result inserts for LP1
						insert into STUD_SUBJ_FINAL (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
						select @StudentID, @EnrolmentYear,  @lpSubjectToCreate, 'AutoJob', GETDATE()

						/* Insert STUD_SUB_INTERIM Table */
						insert into STUD_SUB_INTERIM (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
						select @StudentID, @EnrolmentYear,  @lpSubjectToCreate, 'AutoJob', GETDATE()
					end

					-- 2-June-2017|EA| per service desk #6723 Diane M. remove DL1 enrolments for Primary as no longer needed.
					/*
					if not exists(select * from STUDENT_SUBJECT WHERE SUBJECT_ID = 931 AND STUDENT_ID = @StudentID and ENROLMENT_YEAR = @EnrolmentYear)  
					begin  
						print 'Adding DL1'  
						INSERT INTO STUDENT_SUBJECT  (student_id, enrolment_year, subject_id, staff_id, semester, enrolment_date, subj_enrol_status
							, VBOS_REGISTERED, APPEARS_ON_VASS, NUM_ASSMT_SUBMISSIONS, EXTENSION_OF_VCE_UNIT, course_distribution
							, LAST_ALTERED_BY, LAST_ALTERED_DATE)
						select @StudentID, @EnrolmentYear,  931, 'NA', 'B', GETDATE(), 'C'
						, 1,0,0,0,'I'
						,'AutoJob', GETDATE()
			 
						-- ADD The Interim and Final Result inserts for DL1
						insert into STUD_SUBJ_FINAL (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
						select @StudentID, @EnrolmentYear,  931, 'AutoJob', GETDATE()
				
						/* Insert STUD_SUB_INTERIM Table */
						insert into STUD_SUB_INTERIM (STUDENT_ID,ENROLMENT_YEAR,SUBJECT_ID,LAST_ALTERED_BY, LAST_ALTERED_DATE)
						select @StudentID, @EnrolmentYear,  931, 'AutoJob', GETDATE()

					end	      -- not exists (select * from STUDENT_SUBJECT...  
					*/
				end		--if exists (SELECT YEAR_LEVEL FROM STUDENT_ENROLMENT WHERE YEAR_LEVEL BETWEEN 3 and 6 

				
			COMMIT TRAN   

		END TRY    
      
		BEGIN CATCH    
			ROLLBACK TRAN  
		END CATCH    

	END	-- @StudentID is null

END

