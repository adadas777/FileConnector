






CREATE PROCEDURE [dbo].[SaveFile]
	@id INT
	, @filename NVARCHAR(256)
	, @source NVARCHAR(256)
	, @status VARCHAR(20)
	, @errormessage NVARCHAR(4000)
	, @direction VARCHAR(10)

AS
BEGIN
	DECLARE 
		@message NVARCHAR(4000)
		, @type VARCHAR(10)
		, @procname VARCHAR(50)
		, @startdate DATETIME
		, @prevstatus VARCHAR(20)
		
	SET @direction = TRIM(UPPER(@direction))
	SET @procname = OBJECT_NAME(@@PROCID)

	BEGIN TRY

		EXEC dbo.SaveLog
			@message = 'Starting procedure'
			, @source = @procname
			, @type = 'INFO'

		IF EXISTS (SELECT id FROM [dbo].[Files] WHERE id = @id)
			
			BEGIN
			
				SELECT @prevstatus = [Status]  FROM dbo.Files WHERE id = @id 
			
				IF (SELECT  dbo.CheckStatus(@status, @prevstatus)) <> 1
				
					BEGIN 
						
						SET @message = 'Wrong status change from ' + @prevstatus + ' to ' + @status
					
						EXEC dbo.SaveLog
							@message =@message
							, @source = @procname
							, @type = 'ERROR'
					
						RETURN -1
					END

				IF @status = 'PROCESSING'
				
					BEGIN
						
						UPDATE [dbo].[Files]
						
						SET 
							StartDate = GETDATE() 
							, [EndDate] = null
							, [Status] = 'PROCESSING'
				
					END
		
				IF @status='FINISHED'
				
					BEGIN
					
						UPDATE [dbo].[Files]
						
						SET 
							[EndDate] = GETDATE()
							, [Status] = 'FINISHED'
				
					END

				IF @status = 'ERROR'
				
					BEGIN
				
						UPDATE [dbo].[Files]
						
						SET 
							[Status] = 'ERROR'
							, [ErrorMessage] = @errormessage
				
					END

				END
		
				ELSE 
		
					BEGIN

						SET @message = 'Inserted : ' + @filename + ', ' + @direction
			
			
						INSERT INTO [dbo].[Files]
						(
							[FileName]
							, StartDate
							, [EndDate]
							, [Source]
							, [Status]
							, [ErrorMessage]
							, [Direction]
						)
						VALUES
						(
							@filename
							, null
							, null
							, @source
							, 'CREATED'
							, null
							, @direction
						)

						EXEC dbo.SaveLog
							@message = @message
							, @source = @procname
							, @type = 'INFO'

						EXEC dbo.SaveLog
							@message = 'Ending procedure'
							, @source = @procname
							, @type = 'INFO'
		
					END
	END TRY

	BEGIN CATCH

		SET @message = ERROR_MESSAGE()

		EXEC dbo.SaveLog
			@message = @message
			, @source = @procname
			, @type = 'ERROR'

		RETURN -1

	END CATCH

	RETURN 0

END