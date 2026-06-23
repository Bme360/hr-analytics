-- הוספת קשר לטבלת המועמדים
ALTER TABLE [dbo].[applications]
ADD CONSTRAINT FK_applications_candidates 
FOREIGN KEY (candidate_id) REFERENCES [dbo].[candidates](candidate_id);

-- הוספת קשר לטבלת המשרות
ALTER TABLE [dbo].[applications]
ADD CONSTRAINT FK_applications_jobs 
FOREIGN KEY (job_id) REFERENCES [dbo].[jobs](job_id);


ALTER TABLE [dbo].[interviews]
ADD CONSTRAINT FK_applications_applications 
FOREIGN KEY (application_id) REFERENCES [dbo].[applications](application_id);


ALTER TABLE [dbo].[skills]
ADD CONSTRAINT FK_applications_candidates 
FOREIGN KEY (candidate_id) REFERENCES [dbo].[candidates](candidate_id);

-- קודם נבדוק אם הקשר כבר קיים כדי למנוע שגיאות
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_skills_candidates')
BEGIN
    ALTER TABLE dbo.skills DROP CONSTRAINT FK_skills_candidates;
END

-- עכשיו נוסיף את הקשר לטבלת skills
ALTER TABLE dbo.skills 
ADD CONSTRAINT FK_skills_candidates 
FOREIGN KEY (candidate_id) REFERENCES dbo.candidates(candidate_id);

PRINT '✅ הקשר בין טבלת Skills לטבלת Candidates נוצר בהצלחה!';