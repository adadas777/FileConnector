CREATE TABLE [dbo].[File] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [FileName]     NVARCHAR (256)  NOT NULL,
    [StartDate]    DATETIME        NULL,
    [EndDate]      DATETIME        NULL,
    [Source]       NVARCHAR (256)  NOT NULL,
    [Status]       VARCHAR (20)    NOT NULL,
    [ErrorMessage] NVARCHAR (4000) NULL,
    [Direction]    VARCHAR (10)    NOT NULL,
    CONSTRAINT [PK_File] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_Direction] CHECK ([Direction]='IN' OR [Direction]='OUT'),
    CONSTRAINT [CK_Status] CHECK ([Status]='ERROR' OR [Status]='FINISHED' OR [Status]='PROCESSING' OR [Status]='CREATED')
);

