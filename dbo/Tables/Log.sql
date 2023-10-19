CREATE TABLE [dbo].[Log] (
    [Id]      INT             IDENTITY (1, 1) NOT NULL,
    [Message] NVARCHAR (4000) NOT NULL,
    [Source]  VARCHAR (200)   NOT NULL,
    [Type]    VARCHAR (10)    NOT NULL,
    [LogDate] DATETIME        NOT NULL,
    CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED ([Id] DESC),
    CONSTRAINT [CK_Type] CHECK ([Type]='WARNING' OR [Type]='ERROR' OR [Type]='INFO')
);


GO
CREATE NONCLUSTERED INDEX [I_Type]
    ON [dbo].[Log]([Type] ASC);

