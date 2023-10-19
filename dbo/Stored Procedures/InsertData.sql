









CREATE PROCEDURE [dbo].[InsertData]
AS

BEGIN
	DECLARE
		@folderpath NVARCHAR(256)
		, @filename NVARCHAR(100)
		, @procname VARCHAR(50)
		, @returnvalue INT
		, @key VARCHAR(50)
		, @getproc VARCHAR(50)
		, @getfirstrow NVARCHAR(5)
		, @getfieldterminator  NVARCHAR(5)
		, @getrowterminator NVARCHAR(5)
		, @sql NVARCHAR(1000)
		, @filepath NVARCHAR(50)
		, @message NVARCHAR(4000)
		, @id INT

	SET @procname = OBJECT_NAME(@@PROCID)

	BEGIN TRY
		
		EXEC dbo.SaveLog
			@message ='Starting procedure'
			, @source = @procname
			, @type = 'INFO'

		EXEC [dbo].[CloseDeallocateCursor]
			@cursorname = 'c_listfile'

		DECLARE c_listfile CURSOR STATIC FOR 
			SELECT filename, Id
			FROM Files
			WHERE Status IN ('CREATED', 'ERROR')

		EXEC dbo.GetParameters
			@key = 'FOLDER'
			, @value = @folderpath OUTPUT


		OPEN c_listfile
		FETCH NEXT FROM c_listfile INTO @filename, @id

		WHILE @@FETCH_STATUS = 0
			
			BEGIN
				
				SET	@key = 
					(
						SELECT [Key] 
						FROM [dbo].[Parameters] 
						WHERE Value = @filename
					)
		PRINT @filename
		Print @key
				IF @key is null 

					BEGIN
							
						SET @message = '@key can not be null'

						EXEC [dbo].[SaveFile]
							@id = @id
							, @filename = @filename
							, @source = @folderpath
							, @status = 'ERROR'
							, @errormessage = @message
							, @direction = 'IN'
						
						EXEC dbo.SaveLog
							@message = @message
							, @source = @procname
							, @type = 'ERROR'
						
						FETCH NEXT FROM c_listfile INTO @filename, @id
					END
				
				SET @getproc = 
					(
						SELECT value 
						FROM [dbo].[Parameters] 
						WHERE [key] = @key + '_PROC'
					)
	PRINT @getproc
	Print @key + '_PROC'
				IF @getproc is null 
						
					BEGIN
							
						SET @message = '@getproc can not be null for '+ @filename
									

						EXEC [dbo].[SaveFile]
							@id = @id
							, @filename = @filename
							, @source = @folderpath
							, @status = 'ERROR'
							, @errormessage = @message
							, @direction = 'IN'		
						
						EXEC dbo.SaveLog
							@message = @message
							, @source = @procname
							, @type = 'ERROR'
						
						FETCH NEXT FROM c_listfile INTO @filename, @id
					END
					
					SET @filepath = @folderpath + '\' + @filename
				
					IF @filepath is null 
				
						BEGIN
						
							SET @message = '@filepath can not be null'
				
							EXEC [dbo].[SaveFile]
								@id = @id
								, @filename = @filename
								, @source = @folderpath
								, @status = 'ERROR'
								, @errormessage = @message
								, @direction = 'IN'	
						
							EXEC dbo.SaveLog
								@message = @message
								, @source = @procname
								, @type = 'ERROR'
						
							FETCH NEXT FROM c_listfile INTO @filename, @id
						END
		

				IF lower(right(@filename, charindex('.', reverse(@filename)) - 1)) IN ('txt','csv')

				BEGIN
					SET @getfirstrow = 
						(
							SELECT value 
							FROM [dbo].[Parameters]
							WHERE [key] = @key + '_FIRSTROW'
						)

					IF @getfirstrow is null 
					
						BEGIN
							
							SET @message = '@getfirstrow can not be null'
									

							EXEC [dbo].[SaveFile]
								@id = @id
								, @filename = @filename
								, @source = @folderpath
								, @status = 'ERROR'
								, @errormessage = @message
								, @direction = 'IN'		
						
							EXEC dbo.SaveLog
								@message = @message
								, @source = @procname
								, @type = 'ERROR'
						
							FETCH NEXT FROM c_listfile INTO @filename, @id
						END
				
					SET @getfieldterminator = 
						(
							SELECT value 
							FROM [dbo].[Parameters] 
							WHERE [key] = @key + '_FIELDTERMINATOR'
						)
				
					IF @getfieldterminator is null 
						
						BEGIN

							SET @message = '@getfieldterminator can not be null'
									

							EXEC [dbo].[SaveFile]
								@id = @id
								, @filename = @filename
								, @source = @folderpath
								, @status = 'ERROR'
								, @errormessage = @message
								, @direction = 'IN'		
						
							EXEC dbo.SaveLog
								@message = @message
								, @source = @procname
								, @type = 'ERROR'
						
							FETCH NEXT FROM c_listfile INTO @filename, @id
						END
				
					SET @getrowterminator = 
						(
							SELECT value 
							FROM [dbo].[Parameters] 
							WHERE [key] = @key + '_ROWTERMINATOR'
						)
				
					IF @getrowterminator is null 
						
						BEGIN
	
							SET @message = '@getrowterminator can not be null'
										

							EXEC [dbo].[SaveFile]
								@id = @id
								, @filename = @filename
								, @source = @folderpath
								, @status = 'ERROR'
								, @errormessage = @message
								, @direction = 'IN'		
						
							EXEC dbo.SaveLog
								@message = @message
								, @source = @procname
								, @type = 'ERROR'
						
							FETCH NEXT FROM c_listfile INTO @filename, @id
						END
		
					
					
					SET @sql='
		
					EXEC '+ @getproc+' '+
						'@filepath='''+ @filepath + ''', ' +
						'@firstrow='+@getfirstrow + ', ' +
						'@fieldterminator='''+@getfieldterminator + ''', ' +
						'@rowterminator=''' + @getrowterminator + ''''
				

				END 
				ELSE 
					
					BEGIN
						
						SET @sql='
		
						EXEC ' + @getproc +' ' +
							'@filepath=''' + @filepath + ''''

					END
			
				EXEC @returnvalue = sp_executesql @sql
		
			IF @returnvalue = 0

				BEGIN

					EXEC [dbo].[SaveFile]
						@id = @id
						, @filename = @filename
						, @source = @folderpath
						, @status = 'FINISHED'
						, @errormessage = null
						, @direction = 'IN'		

					EXEC dbo.SaveLog
						@message ='Ending procedure'
						, @source = @procname
						, @type = 'INFO'
				
				END

			ELSE IF @returnvalue <> 0 

				BEGIN
						
					SET @message = 'Error when exec import proc'

					EXEC [dbo].[SaveFile]
						@id = @id
						, @filename = @filename
						, @source = @folderpath
						, @status = 'ERROR'
						, @errormessage = @message
						, @direction = 'IN'	
		
					EXEC dbo.SaveLog
						@message = @message
						, @source = @procname
						, @type = 'ERROR'

					FETCH NEXT FROM c_listfile INTO @filename, @id
				END
		
			FETCH NEXT FROM c_listfile INTO @filename, @id
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