CREATE TABLE [dbo].[Organization] (
    [Index]             NVARCHAR (4)    NOT NULL,
    [OrganizationId]    NVARCHAR (50)   NULL,
    [Name]              NVARCHAR (50)   NULL,
    [Website]           NVARCHAR (50)   NULL,
    [Country]           NVARCHAR (50)   NULL,
    [Description]       NVARCHAR (1000) NULL,
    [Founded]           NVARCHAR (100)  NULL,
    [Industry]          NVARCHAR (100)  NULL,
    [NumberofEmployees] NVARCHAR (100)  NULL
);

