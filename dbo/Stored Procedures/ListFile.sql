









CREATE PROCEDURE [dbo].[ListFile]

AS
BEGIN
	DECLARE 
		@procname VARCHAR(50)
		, @folderpath NVARCHAR(256)
		, @cmd NVARCHAR(256)
		, @filename VARCHAR(100)
		, @message NVARCHAR(4000)
	
	SET @procname = OBJECT_NAME(@@PROCID)
	
	BEGIN TRY
		
		IF OBJECT_ID('tempdb..#listfile') IS NOT NULL DROP TABLE #listfile
		
		CREATE TABLE #listfile (filepath VARCHAR(500))

		EXEC [dbo].[CloseDeallocateCursor]
			@cursorname = 'c_listfile'

		DECLARE c_listfile CURSOR FOR 
		SELECT filepath
		FROM #listfile
		WHERE filepath is not null

		EXEC dbo.GetParameters
			@key = 'FOLDER'
			, @value = @folderpath OUTPUT

		SET @cmd = 'dir /B '+@folderpath

		INSERT INTO #listfile
	
		EXEC xp_cmdshell @cmd;

		OPEN c_listfile
		FETCH NEXT FROM c_listfile INTO @filename

		WHILE @@FETCH_STATUS = 0
			BEGIN
		
				IF NOT EXISTS
				(
					SELECT Id
					FROM [dbo].[Files]
					WHERE FileName= @filename
				) 

				BEGIN

					EXEC [dbo].[SaveFile]
						@id = null
						, @filename = @filename
						, @source = @folderpath
						, @status = 'CREATED'
						, @errormessage = null
						, @direction = 'IN'
				END

			FETCH NEXT FROM c_listfile INTO @filename
			END 
	
	END TRY
	
	BEGIN CATCH
		
		SET @message = 'Error list files: ' + ERROR_MESSAGE()
		
		EXEC dbo.SaveLog
			@message = @message
			, @source = @procname
			, @type = 'ERROR'

		EXEC [dbo].[CloseDeallocateCursor]
			@cursorname = 'c_listfile'

		IF OBJECT_ID('tempdb..#listfile') IS NOT NULL DROP TABLE #listfile
		
	RETURN -1

	END CATCH

	EXEC [dbo].[CloseDeallocateCursor]
		@cursorname = 'c_listfile'


	IF OBJECT_ID('tempdb..#listfile') IS NOT NULL DROP TABLE #listfile
		
	RETURN 0

END