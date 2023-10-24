









CREATE PROCEDURE [dbo].[ZipFile]

AS
BEGIN
	DECLARE
		@folderpath VARCHAR(256)
		, @filename VARCHAR(100)
		, @procname VARCHAR(50)
		, @cmd VARCHAR(4000)
		, @bakfolderpath VARCHAR(100)
		, @7zippath VARCHAR(100)
		, @message NVARCHAR(4000)

	SET @procname = OBJECT_NAME(@@PROCID)

	BEGIN TRY
		
			EXEC [dbo].[CloseDeallocateCursor]
				@cursorname = 'c_listfile'

		DECLARE c_listfile CURSOR FOR 
		SELECT filename 
		FROM [File]
		WHERE Status IN ('FINISHED')

		EXEC dbo.GetParameter
			@key = 'FOLDER'
			, @value = @folderpath OUTPUT

		EXEC dbo.GetParameter
			@key = 'BAK_FOLDER'
			, @value = @bakfolderpath OUTPUT

		EXEC dbo.GetParameter
			@key = '7ZIP_FOLDER'
			, @value = @7zippath OUTPUT

		OPEN c_listfile
		FETCH NEXT FROM c_listfile 
		INTO @filename

		WHILE @@FETCH_STATUS = 0
			
			BEGIN

				SET @cmd = 'move ' + @folderpath + '\' + @filename + ' ' + @bakfolderpath + '\'
			
				EXEC xp_cmdshell @cmd

				SET @cmd = @7zippath + ' a ' + @bakfolderpath + '\' + LEFT(@filename + '.'
				, CHARINDEX('.', @filename + '.')-1) + '.7z' + ' ' + @bakfolderpath + '\' + @filename
Print(@cmd)
				EXEC xp_cmdshell @cmd

				FETCH NEXT FROM c_listfile 
				INTO @filename
				
			END
	END TRY

	BEGIN CATCH
		
		SET @message = ERROR_MESSAGE()
		
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