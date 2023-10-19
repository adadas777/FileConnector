



CREATE PROCEDURE [dbo].[Run]

AS
BEGIN
	DECLARE
		@returnvalue INT
		, @message NVARCHAR(4000)
		, @procname VARCHAR(50)

	SET @procname = OBJECT_NAME(@@PROCID)

	SET @message = 'Starting procedure'
		
	EXEC dbo.SaveLog
		@message =@message
		, @source = @procname
		, @type = 'INFO'

	EXEC @returnvalue = [dbo].[ListFile]

	IF @returnvalue <> 0 
		
		BEGIN
			
			SET @message = 'Error when exec ListFile'
		
			EXEC dbo.SaveLog
				@message =@message,
				@source = @procname,
				@type = 'ERROR'

			RETURN -1
		END

	EXEC @returnvalue = [dbo].[InsertData]

	IF @returnvalue <> 0 
		
		BEGIN
			
			SET @message = 'Error when exec InsertData'
		
			EXEC dbo.SaveLog
				@message = @message
				, @source = @procname
				, @type = 'ERROR'

			RETURN -1
		END

	EXEC @returnvalue = [dbo].[ZipFile]

	IF @returnvalue <> 0 
		
		BEGIN
			
			SET @message = 'Error when exec ZipFile'
		
			EXEC dbo.SaveLog
				@message = @message
				, @source = @procname
				, @type = 'ERROR'

			RETURN -1
		END

	SET @message = 'Ending procedure'
		
	EXEC dbo.SaveLog
		@message = @message
		, @source = @procname
		, @type = 'INFO'

END