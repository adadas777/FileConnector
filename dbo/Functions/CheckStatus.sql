


CREATE FUNCTION [dbo].[CheckStatus]
(
    @newstatus VARCHAR(20),
    @prevstatus VARCHAR(20)
)

RETURNS INT
AS 

BEGIN

    IF @newstatus = 'CREATED' AND @prevstatus <> null 

		BEGIN
			RETURN 0
		END

	IF @newstatus = 'PROCESSING' AND @prevstatus not in ('CREATED','ERROR') 

		BEGIN
			RETURN 0
		END

	IF @newstatus = 'FINSHED' AND @prevstatus not in ('PROCESSING')

		BEGIN
			RETURN 0
		END

	IF @newstatus = 'ERROR' AND @prevstatus not in ('PROCESSING')

		BEGIN
			RETURN 0
		END

	RETURN 1

END;