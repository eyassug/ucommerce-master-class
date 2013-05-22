USE [master]
GO
/****** Object:  Database [UTraining3]    Script Date: 22-05-2013 09:38:52 ******/
CREATE DATABASE [UTraining3]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'UTraining3', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\UTraining3.mdf' , SIZE = 7168KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'UTraining3_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\UTraining3_log.ldf' , SIZE = 2560KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [UTraining3] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [UTraining3].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [UTraining3] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [UTraining3] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [UTraining3] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [UTraining3] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [UTraining3] SET ARITHABORT OFF 
GO
ALTER DATABASE [UTraining3] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [UTraining3] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [UTraining3] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [UTraining3] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [UTraining3] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [UTraining3] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [UTraining3] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [UTraining3] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [UTraining3] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [UTraining3] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [UTraining3] SET  DISABLE_BROKER 
GO
ALTER DATABASE [UTraining3] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [UTraining3] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [UTraining3] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [UTraining3] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [UTraining3] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [UTraining3] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [UTraining3] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [UTraining3] SET RECOVERY FULL 
GO
ALTER DATABASE [UTraining3] SET  MULTI_USER 
GO
ALTER DATABASE [UTraining3] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [UTraining3] SET DB_CHAINING OFF 
GO
ALTER DATABASE [UTraining3] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [UTraining3] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'UTraining3', N'ON'
GO
USE [UTraining3]
GO
/****** Object:  StoredProcedure [dbo].[uCommerce_GetOrderNumber]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uCommerce_GetOrderNumber]
	@OrderNumberName NVARCHAR(128)
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @OrderNumber NVARCHAR(256);

	BEGIN TRANSACTION
		SELECT @OrderNumber = ISNULL(Prefix,'') + CONVERT(NVARCHAR(256),(CurrentNumber + Increment)) + ISNULL(Postfix,'') FROM uCommerce_OrderNumberSerie WHERE OrderNumberName = @OrderNumberName;
		UPDATE uCommerce_OrderNumberSerie
		SET CurrentNumber = CurrentNumber + Increment
		WHERE OrderNumberName = @OrderNumberName
	IF @@ERROR <> 0
	BEGIN	
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		COMMIT TRANSACTION
	END

	SELECT @OrderNumber OrderNumber;
    
END
GO
/****** Object:  StoredProcedure [dbo].[uCommerce_GetProductTop10]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Fix for proc including "Cancelled orders"
CREATE PROCEDURE [dbo].[uCommerce_GetProductTop10]
( 
	@ProductCatalogGroupId INT
)
AS
	SET NOCOUNT ON
	
	SELECT TOP 10
		dbo.uCommerce_ProductCatalogGroup.Name,
		dbo.uCommerce_OrderLine.Sku,
		dbo.uCommerce_OrderLine.VariantSku,
		dbo.uCommerce_OrderLine.ProductName,
		SUM(dbo.uCommerce_OrderLine.Quantity) TotalSales,
		SUM(ISNULL(dbo.uCommerce_OrderLine.Total, 0)) TotalRevenue,
		dbo.uCommerce_Currency.ISOCode Currency
	FROM
		dbo.uCommerce_OrderLine
		JOIN dbo.uCommerce_PurchaseOrder ON dbo.uCommerce_PurchaseOrder.OrderId = dbo.uCommerce_OrderLine.OrderId
		JOIN dbo.uCommerce_Currency ON dbo.uCommerce_Currency.CurrencyId = dbo.uCommerce_PurchaseOrder.CurrencyId
		LEFT JOIN dbo.uCommerce_ProductCatalogGroup ON dbo.uCommerce_ProductCatalogGroup.ProductCatalogGroupId = dbo.uCommerce_PurchaseOrder.ProductCatalogGroupId
	WHERE
		(	dbo.uCommerce_ProductCatalogGroup.ProductCatalogGroupId = @ProductCatalogGroupId
			OR
			@ProductCatalogGroupId IS NULL
		)
		AND
			dbo.uCommerce_PurchaseOrder.OrderStatusId in (2, 3, 5, 6, 1000000) -- New order, Completed order, Invoiced, Paid, Requires Attention
	GROUP BY
		dbo.uCommerce_OrderLine.Sku,
		dbo.uCommerce_OrderLine.VariantSku,
		dbo.uCommerce_OrderLine.ProductName,
		dbo.uCommerce_ProductCatalogGroup.Name,
		dbo.uCommerce_Currency.ISOCode
	ORDER BY
		SUM(dbo.uCommerce_OrderLine.Quantity) DESC,
		dbo.uCommerce_ProductCatalogGroup.Name

GO
/****** Object:  StoredProcedure [dbo].[uCommerce_GetProductView]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[uCommerce_GetProductView] 
	@ProductCatalogId INT,
	@CategoryID INT,
	@CultureCode NVARCHAR(50),
	@ProductId INT = NULL,
	@IncludeVariants BIT = 0,
	@IncludeInvisibleProducts BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
            dbo.Product.ProductId, 
			dbo.Product.Sku, 
			dbo.Product.VariantSku, 
			dbo.Product.Name, 
			dbo.Product.DisplayOnSite, 
			dbo.Product.PrimaryImageMediaId, 
            dbo.Currency.ISOCode AS Currency, 
			dbo.PriceGroup.VATRate, 
			dbo.PriceGroupPrice.DiscountPrice AS DiscountPriceAmount, 
			dbo.PriceGroupPrice.Price AS PriceAmount, 
            dbo.ProductDefinition.Name AS ProductDefinitionDisplayName, 
			dbo.ProductDescription.CultureCode, dbo.ProductDescription.DisplayName, 
            dbo.ProductDescription.ShortDescription, 
			dbo.ProductDescription.LongDescription, 
			dbo.InventoryRecord.OnHandQuantity, 
			dbo.InventoryRecord.ReservedQuantity,                     
			dbo.InventoryRecord.Location, 
			dbo.ProductCatalog.Name AS ProductCatalogName, 
			dbo.ProductCatalog.ShowPricesIncludingVAT AS ShowPriceIncludingVAT,
			dbo.Product.ThumbnailImageMediaId
	FROM 
			dbo.Product 
			INNER JOIN dbo.ProductDefinition ON dbo.Product.ProductDefinitionId = dbo.ProductDefinition.ProductDefinitionId 
			INNER JOIN dbo.ProductDescription ON dbo.Product.ProductId = dbo.ProductDescription.ProductId -- Sproget version af beskrivelse, en række per sprog
			-- Catalog info
			LEFT JOIN dbo.CategoryProductRelation ON dbo.CategoryProductRelation.ProductId = dbo.Product.ProductId
			LEFT JOIN dbo.Category ON dbo.Category.CategoryId = dbo.CategoryProductRelation.CategoryId
			LEFT JOIN dbo.ProductCatalog ON dbo.ProductCatalog.ProductCatalogId = dbo.Category.ProductCatalogId
			-- Pricing Info
			LEFT JOIN dbo.PriceGroupPrice ON dbo.PriceGroupPrice.ProductId = dbo.Product.ProductId AND dbo.ProductCatalog.PriceGroupId = dbo.PriceGroupPrice.PriceGroupId
			LEFT JOIN dbo.PriceGroup ON dbo.PriceGroup.PriceGroupId = dbo.PriceGroupPrice.PriceGroupId
			LEFT JOIN dbo.Currency ON dbo.Currency.CurrencyId = dbo.PriceGroup.CurrencyId
			-- Inventory info
			LEFT OUTER JOIN dbo.Inventory ON dbo.ProductCatalog.InventoryId = dbo.Inventory.InventoryId 
			LEFT OUTER JOIN dbo.InventoryRecord ON dbo.Product.ProductId = dbo.InventoryRecord.ProductId AND dbo.Inventory.InventoryId = dbo.InventoryRecord.InventoryId
WHERE		
			(dbo.ProductCatalog.ProductCatalogId = @ProductCatalogId) AND 
			(dbo.ProductDescription.CultureCode = @CultureCode) AND 
			(dbo.CategoryProductRelation.CategoryId = @CategoryId) AND 
			(dbo.Product.ProductId = @ProductId OR @ProductId IS NULL) AND
			(dbo.Product.VariantSKU IS NULL OR @IncludeVariants = 1) 
			AND
			(
				(dbo.Product.DisplayOnSite = 1)
				OR
				(@IncludeInvisibleProducts = 1)
			)
END

GO
/****** Object:  StoredProcedure [dbo].[uCommerce_GetTotalSales]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uCommerce_GetTotalSales]
(
	@StartDate DATETIME, -- NULLABLE
	@EndDate DATETIME, -- NULLABLE
	@ProductCatalogGroupId INT -- NULLABLE
)
AS
	SET NOCOUNT ON
	SELECT 
		dbo.uCommerce_ProductCatalogGroup.Name,
		SUM(ISNULL(dbo.uCommerce_PurchaseOrder.OrderTotal, 0)) Revenue,
		SUM(ISNULL(dbo.uCommerce_PurchaseOrder.VAT, 0)) [VATTotal],
		SUM(ISNULL(dbo.uCommerce_PurchaseOrder.TaxTotal, 0)) [TaxTotal],
		SUM(ISNULL(dbo.uCommerce_PurchaseOrder.ShippingTotal, 0)) [ShippingTotal],
		ISNULL(dbo.uCommerce_Currency.ISOCode, '-') Currency
	FROM
		dbo.uCommerce_PurchaseOrder
		JOIN dbo.uCommerce_Currency ON dbo.uCommerce_Currency.CurrencyId = dbo.uCommerce_PurchaseOrder.CurrencyId
		RIGHT JOIN dbo.uCommerce_ProductCatalogGroup ON dbo.uCommerce_ProductCatalogGroup.ProductCatalogGroupId = dbo.uCommerce_PurchaseOrder.ProductCatalogGroupId
	WHERE
		(
			dbo.uCommerce_PurchaseOrder.CreatedDate BETWEEN @StartDate AND @EndDate
			OR
			(
				@StartDate IS NULL
				AND
				@EndDate IS NULL
			)
			OR
			dbo.uCommerce_PurchaseOrder.CreatedDate IS NULL
		)
		AND
		(
			dbo.uCommerce_ProductCatalogGroup.ProductCatalogGroupId = @ProductCatalogGroupId
			OR
			@ProductCatalogGroupId IS NULL
		)
		AND
		(
			NOT dbo.uCommerce_PurchaseOrder.OrderStatusId IN (1, 4, 7) -- Basket, -- Cancelled Order, -- Cancelled
			OR
			dbo.uCommerce_PurchaseOrder.OrderStatusId IS NULL
		)
	GROUP BY
		dbo.uCommerce_ProductCatalogGroup.Name,
		dbo.uCommerce_Currency.ISOCode

GO
/****** Object:  StoredProcedure [dbo].[uCommerce_ProductSearchSimple]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uCommerce_ProductSearchSimple] 
	@SearchTerm NVARCHAR(MAX),
	@LimitToCatalogIds NVARCHAR(MAX) -- comma separeted string of ints
AS
	SET NOCOUNT ON

	-- Escape special characters
	SELECT @SearchTerm = 
					REPLACE( 
					REPLACE( 
					REPLACE( 
					REPLACE(
					REPLACE(
					REPLACE( @SearchTerm
					,    '\', '\\'  )
					,	 '--', ''   )
					,	 '''', '\''')                
					,    '%', '\%'  )
					,    '_', '\_'  )
					,    '[', '\['  )

	SELECT @SearchTerm = '%' + @SearchTerm + '%'

	SELECT DISTINCT
		 Product.*
	FROM
		Product
		JOIN ProductProperty
			ON ProductProperty.ProductId = Product.ProductId
		JOIN ProductDefinitionField
			ON ProductDefinitionField.ProductDefinitionFieldId = ProductProperty.ProductDefinitionFieldId
		LEFT JOIN CategoryProductRelation
			ON CategoryProductRelation.ProductId = Product.ProductId
		LEFT JOIN Category
			ON Category.CategoryId = CategoryProductRelation.CategoryId
		LEFT JOIN ProductCatalog
			ON ProductCatalog.ProductCatalogId = Category.ProductCatalogId
		LEFT JOIN dbo.ParseArrayToTable(@LimitToCatalogIds, ';', 1) LimitToCatalogIdsTable
			ON LimitToCatalogIdsTable.NumericValue = ProductCatalog.ProductCatalogId OR @LimitToCatalogIds = '' OR @LimitToCatalogIds IS NULL
	WHERE
		(
			CategoryProductRelation.CategoryId IS NOT NULL
			AND
			(
				Product.Sku LIKE @SearchTerm
				OR
				Product.VariantSku LIKE @SearchTerm
				OR
				Product.Name LIKE @SearchTerm
				OR
				ProductProperty.Value LIKE @SearchTerm
			)
		)	
		OR
		(	-- Include products not in any category, which also matches the search term
			CategoryProductRelation.CategoryId IS NULL
			AND
			(	-- But only if no catalog ids to limit to were provided
				@LimitToCatalogIds IS NULL 
				OR
				@LimitToCatalogIds = ''
			)
			AND
			(
				Product.Sku LIKE @SearchTerm
				OR
				Product.VariantSku LIKE @SearchTerm
				OR
				Product.Name LIKE @SearchTerm
				OR
				ProductProperty.Value LIKE @SearchTerm
			)
		)				

GO
/****** Object:  UserDefinedFunction [dbo].[uCommerce_ParseArrayToTable]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[uCommerce_ParseArrayToTable]
(
	@Array NVARCHAR(MAX), 		-- String to parse (ie: '1,2,6,4,12')
	@Separator CHAR(1) = ',',	-- Seperator to use, default to ',' (comma)
	@ReturnAsNumeric BIT = 0	-- If true, returns numeric values in stead of varchars
)
RETURNS @table TABLE
(
	[Id] INT IDENTITY(1, 1),
	stringvalue NVARCHAR(MAX),
	numericvalue INT
)
AS
BEGIN

	DECLARE @Separator_Position int 		-- This is used to locate each separator character
	DECLARE @Array_Value NVARCHAR(MAX) 	-- This holds each array value as it is returned

	-- For my loop to work I need an extra separator at the end.  I always look to the
	-- left of the separator character for each array value
	SET @Array = @Array + @Separator

	WHILE Patindex('%' + @Separator + '%' , @Array) <> 0 
	BEGIN			
		-- Patindex matches the a pattern against a string
		SELECT @Separator_position =  Patindex('%' + @Separator + '%' , @Array)
		SELECT @Array_value = Left(@Array, @Separator_Position - 1)

		-- This is where you process the values passed.
		-- Replace this select statement with your processing
		-- @Array_Value holds the value of this element of the array
		-- If the value is not numeric, insert as a string (using '')
		IF @ReturnAsNumeric = 1
			INSERT @table (numericvalue) VALUES (CONVERT(INT, @Array_Value))
		ELSE
			INSERT @table (stringvalue) VALUES (CONVERT(NVARCHAR(MAX), @Array_Value))

		-- This replaces what we just processed with an empty string
		SELECT @Array = Stuff(@Array, 1, @Separator_Position, '')

	END

	RETURN

END
GO
/****** Object:  Table [dbo].[cmsContent]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsContent](
	[pk] [int] IDENTITY(1,1) NOT NULL,
	[nodeId] [int] NOT NULL,
	[contentType] [int] NOT NULL,
 CONSTRAINT [PK_cmsContent] PRIMARY KEY CLUSTERED 
(
	[pk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsContentType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsContentType](
	[pk] [int] IDENTITY(1,1) NOT NULL,
	[nodeId] [int] NOT NULL,
	[alias] [nvarchar](255) NULL,
	[icon] [nvarchar](255) NULL,
	[thumbnail] [nvarchar](255) NOT NULL,
	[description] [nvarchar](1500) NULL,
	[isContainer] [bit] NOT NULL,
	[allowAtRoot] [bit] NOT NULL,
 CONSTRAINT [PK_cmsContentType] PRIMARY KEY CLUSTERED 
(
	[pk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsContentType2ContentType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsContentType2ContentType](
	[parentContentTypeId] [int] NOT NULL,
	[childContentTypeId] [int] NOT NULL,
 CONSTRAINT [PK_cmsContentType2ContentType] PRIMARY KEY CLUSTERED 
(
	[parentContentTypeId] ASC,
	[childContentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsContentTypeAllowedContentType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsContentTypeAllowedContentType](
	[Id] [int] NOT NULL,
	[AllowedId] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_cmsContentTypeAllowedContentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC,
	[AllowedId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsContentVersion]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsContentVersion](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ContentId] [int] NOT NULL,
	[VersionId] [uniqueidentifier] NOT NULL,
	[VersionDate] [datetime] NOT NULL,
	[LanguageLocale] [nvarchar](10) NULL,
 CONSTRAINT [PK_cmsContentVersion] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsContentXml]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsContentXml](
	[nodeId] [int] NOT NULL,
	[xml] [ntext] NOT NULL,
 CONSTRAINT [PK_cmsContentXml] PRIMARY KEY CLUSTERED 
(
	[nodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsDataType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsDataType](
	[pk] [int] IDENTITY(1,1) NOT NULL,
	[nodeId] [int] NOT NULL,
	[controlId] [uniqueidentifier] NOT NULL,
	[dbType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_cmsDataType] PRIMARY KEY CLUSTERED 
(
	[pk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsDataTypePreValues]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsDataTypePreValues](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[datatypeNodeId] [int] NOT NULL,
	[value] [nvarchar](2500) NULL,
	[sortorder] [int] NOT NULL,
	[alias] [nvarchar](50) NULL,
 CONSTRAINT [PK_cmsDataTypePreValues] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsDictionary]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsDictionary](
	[pk] [int] IDENTITY(1,1) NOT NULL,
	[id] [uniqueidentifier] NOT NULL,
	[parent] [uniqueidentifier] NOT NULL,
	[key] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_cmsDictionary] PRIMARY KEY CLUSTERED 
(
	[pk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsDocument]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsDocument](
	[nodeId] [int] NOT NULL,
	[published] [bit] NOT NULL,
	[documentUser] [int] NOT NULL,
	[versionId] [uniqueidentifier] NOT NULL,
	[text] [nvarchar](255) NOT NULL,
	[releaseDate] [datetime] NULL,
	[expireDate] [datetime] NULL,
	[updateDate] [datetime] NOT NULL,
	[templateId] [int] NULL,
	[alias] [nvarchar](255) NULL,
	[newest] [bit] NOT NULL,
 CONSTRAINT [PK_cmsDocument] PRIMARY KEY CLUSTERED 
(
	[versionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsDocumentType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsDocumentType](
	[contentTypeNodeId] [int] NOT NULL,
	[templateNodeId] [int] NOT NULL,
	[IsDefault] [bit] NOT NULL,
 CONSTRAINT [PK_cmsDocumentType] PRIMARY KEY CLUSTERED 
(
	[contentTypeNodeId] ASC,
	[templateNodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsLanguageText]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsLanguageText](
	[pk] [int] IDENTITY(1,1) NOT NULL,
	[languageId] [int] NOT NULL,
	[UniqueId] [uniqueidentifier] NOT NULL,
	[value] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_cmsLanguageText] PRIMARY KEY CLUSTERED 
(
	[pk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsMacro]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMacro](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[macroUseInEditor] [bit] NOT NULL,
	[macroRefreshRate] [int] NOT NULL,
	[macroAlias] [nvarchar](255) NOT NULL,
	[macroName] [nvarchar](255) NULL,
	[macroScriptType] [nvarchar](255) NULL,
	[macroScriptAssembly] [nvarchar](255) NULL,
	[macroXSLT] [nvarchar](255) NULL,
	[macroCacheByPage] [bit] NOT NULL,
	[macroCachePersonalized] [bit] NOT NULL,
	[macroDontRender] [bit] NOT NULL,
	[macroPython] [nvarchar](255) NULL,
 CONSTRAINT [PK_cmsMacro] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsMacroProperty]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMacroProperty](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[macroPropertyHidden] [bit] NOT NULL,
	[macroPropertyType] [int] NOT NULL,
	[macro] [int] NOT NULL,
	[macroPropertySortOrder] [int] NOT NULL,
	[macroPropertyAlias] [nvarchar](50) NOT NULL,
	[macroPropertyName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_cmsMacroProperty] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsMacroPropertyType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMacroPropertyType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[macroPropertyTypeAlias] [nvarchar](50) NULL,
	[macroPropertyTypeRenderAssembly] [nvarchar](255) NULL,
	[macroPropertyTypeRenderType] [nvarchar](255) NULL,
	[macroPropertyTypeBaseType] [nvarchar](255) NULL,
 CONSTRAINT [PK_cmsMacroPropertyType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsMember]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMember](
	[nodeId] [int] NOT NULL,
	[Email] [nvarchar](1000) NOT NULL,
	[LoginName] [nvarchar](1000) NOT NULL,
	[Password] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_cmsMember] PRIMARY KEY CLUSTERED 
(
	[nodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsMember2MemberGroup]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMember2MemberGroup](
	[Member] [int] NOT NULL,
	[MemberGroup] [int] NOT NULL,
 CONSTRAINT [PK_cmsMember2MemberGroup] PRIMARY KEY CLUSTERED 
(
	[Member] ASC,
	[MemberGroup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsMemberType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMemberType](
	[pk] [int] IDENTITY(1,1) NOT NULL,
	[NodeId] [int] NOT NULL,
	[propertytypeId] [int] NOT NULL,
	[memberCanEdit] [bit] NOT NULL,
	[viewOnProfile] [bit] NOT NULL,
 CONSTRAINT [PK_cmsMemberType] PRIMARY KEY CLUSTERED 
(
	[pk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsPreviewXml]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPreviewXml](
	[nodeId] [int] NOT NULL,
	[versionId] [uniqueidentifier] NOT NULL,
	[timestamp] [datetime] NOT NULL,
	[xml] [ntext] NOT NULL,
 CONSTRAINT [PK_cmsPreviewXml] PRIMARY KEY CLUSTERED 
(
	[nodeId] ASC,
	[versionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsPropertyData]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPropertyData](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[contentNodeId] [int] NOT NULL,
	[versionId] [uniqueidentifier] NULL,
	[propertytypeid] [int] NOT NULL,
	[dataInt] [int] NULL,
	[dataDate] [datetime] NULL,
	[dataNvarchar] [nvarchar](500) NULL,
	[dataNtext] [ntext] NULL,
 CONSTRAINT [PK_cmsPropertyData] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsPropertyType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPropertyType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dataTypeId] [int] NOT NULL,
	[contentTypeId] [int] NOT NULL,
	[propertyTypeGroupId] [int] NULL,
	[Alias] [nvarchar](255) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[helpText] [nvarchar](1000) NULL,
	[sortOrder] [int] NOT NULL,
	[mandatory] [bit] NOT NULL,
	[validationRegExp] [nvarchar](255) NULL,
	[Description] [nvarchar](2000) NULL,
 CONSTRAINT [PK_cmsPropertyType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsPropertyTypeGroup]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPropertyTypeGroup](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[parentGroupId] [int] NULL,
	[contenttypeNodeId] [int] NOT NULL,
	[text] [nvarchar](255) NOT NULL,
	[sortorder] [int] NOT NULL,
 CONSTRAINT [PK_cmsPropertyTypeGroup] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsStylesheet]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsStylesheet](
	[nodeId] [int] NOT NULL,
	[filename] [nvarchar](100) NOT NULL,
	[content] [ntext] NULL,
 CONSTRAINT [PK_cmsStylesheet] PRIMARY KEY CLUSTERED 
(
	[nodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsStylesheetProperty]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsStylesheetProperty](
	[nodeId] [int] NOT NULL,
	[stylesheetPropertyEditor] [bit] NULL,
	[stylesheetPropertyAlias] [nvarchar](50) NULL,
	[stylesheetPropertyValue] [nvarchar](400) NULL,
 CONSTRAINT [PK_cmsStylesheetProperty] PRIMARY KEY CLUSTERED 
(
	[nodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsTagRelationship]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTagRelationship](
	[nodeId] [int] NOT NULL,
	[tagId] [int] NOT NULL,
 CONSTRAINT [PK_cmsTagRelationship] PRIMARY KEY CLUSTERED 
(
	[nodeId] ASC,
	[tagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsTags]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTags](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[tag] [nvarchar](200) NULL,
	[ParentId] [int] NULL,
	[group] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsTags] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsTask]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTask](
	[closed] [bit] NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[taskTypeId] [int] NOT NULL,
	[nodeId] [int] NOT NULL,
	[parentUserId] [int] NOT NULL,
	[userId] [int] NOT NULL,
	[DateTime] [datetime] NOT NULL,
	[Comment] [nvarchar](500) NULL,
 CONSTRAINT [PK_cmsTask] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsTaskType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTaskType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[alias] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_cmsTaskType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cmsTemplate]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTemplate](
	[pk] [int] IDENTITY(1,1) NOT NULL,
	[nodeId] [int] NOT NULL,
	[master] [int] NULL,
	[alias] [nvarchar](100) NULL,
	[design] [ntext] NOT NULL,
 CONSTRAINT [PK_cmsTemplate] PRIMARY KEY CLUSTERED 
(
	[pk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Address]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Address](
	[AddressId] [int] IDENTITY(1,1) NOT NULL,
	[Line1] [nvarchar](512) NOT NULL,
	[Line2] [nvarchar](512) NULL,
	[PostalCode] [nvarchar](50) NOT NULL,
	[City] [nvarchar](512) NOT NULL,
	[State] [nvarchar](512) NULL,
	[CountryId] [int] NOT NULL,
	[Attention] [nvarchar](512) NULL,
	[CustomerId] [int] NOT NULL,
	[CompanyName] [nvarchar](512) NULL,
	[AddressName] [nvarchar](512) NOT NULL,
	[FirstName] [nvarchar](512) NULL,
	[LastName] [nvarchar](512) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[MobilePhoneNumber] [nvarchar](50) NULL,
 CONSTRAINT [uCommerce_PK_Address] PRIMARY KEY CLUSTERED 
(
	[AddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_AdminPage]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_AdminPage](
	[AdminPageId] [int] IDENTITY(1,1) NOT NULL,
	[FullName] [nvarchar](256) NOT NULL,
	[ActiveTab] [nvarchar](256) NOT NULL,
 CONSTRAINT [uCommerce_PK_AdminPage] PRIMARY KEY CLUSTERED 
(
	[AdminPageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_AdminTab]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_AdminTab](
	[AdminTabId] [int] IDENTITY(1,1) NOT NULL,
	[VirtualPath] [nvarchar](512) NOT NULL,
	[AdminPageId] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[MultiLingual] [bit] NOT NULL,
	[ResouceKey] [nvarchar](256) NULL,
	[HasSaveButton] [bit] NOT NULL,
	[HasDeleteButton] [bit] NOT NULL,
	[Enabled] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_AdminTab] PRIMARY KEY CLUSTERED 
(
	[AdminTabId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_AmountOffOrderLinesAward]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_AmountOffOrderLinesAward](
	[AmountOffOrderLinesAwardId] [int] NOT NULL,
	[AmountOff] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_uCommerce_AmountOffOrderLinesAward] PRIMARY KEY CLUSTERED 
(
	[AmountOffOrderLinesAwardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_AmountOffOrderTotalAward]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_AmountOffOrderTotalAward](
	[AmountOffOrderTotalAwardId] [int] NOT NULL,
	[AmountOff] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_uCommerce_AmountOffOrderTotalAward_1] PRIMARY KEY CLUSTERED 
(
	[AmountOffOrderTotalAwardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_AmountOffUnitAward]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_AmountOffUnitAward](
	[AmountOffUnitAwardId] [int] NOT NULL,
	[AmountOff] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_uCommerce_AmountOffUnitAward] PRIMARY KEY CLUSTERED 
(
	[AmountOffUnitAwardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Award]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Award](
	[AwardId] [int] IDENTITY(1,1) NOT NULL,
	[CampaignItemId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_uCommerce_Award] PRIMARY KEY CLUSTERED 
(
	[AwardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Campaign]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Campaign](
	[CampaignId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](512) NULL,
	[StartsOn] [datetime] NOT NULL,
	[EndsOn] [datetime] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[Priority] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_uCommerce_Campaign] PRIMARY KEY CLUSTERED 
(
	[CampaignId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_CampaignItem]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_CampaignItem](
	[CampaignItemId] [int] IDENTITY(1,1) NOT NULL,
	[CampaignId] [int] NOT NULL,
	[DefinitionId] [int] NOT NULL,
	[Name] [nvarchar](512) NULL,
	[Enabled] [bit] NOT NULL,
	[Priority] [int] NULL,
	[AllowNextCampaignItems] [bit] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [PK_uCommerce_CampaignItem] PRIMARY KEY CLUSTERED 
(
	[CampaignItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_CampaignItemProperty]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_CampaignItemProperty](
	[CampaignItemPropertyId] [int] IDENTITY(1,1) NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[DefinitionFieldId] [int] NOT NULL,
	[CultureCode] [nvarchar](60) NULL,
	[CampaignItemId] [int] NOT NULL,
 CONSTRAINT [PK_uCommerce_CampaignItemProperty] PRIMARY KEY CLUSTERED 
(
	[CampaignItemPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Category]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Category](
	[CategoryId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](60) NOT NULL,
	[ImageMediaId] [nvarchar](100) NULL,
	[DisplayOnSite] [bit] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ParentCategoryId] [int] NULL,
	[ProductCatalogId] [int] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[Deleted] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[DefinitionId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_Category] PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_CategoryDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_CategoryDescription](
	[CategoryDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NOT NULL,
	[DisplayName] [nvarchar](512) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
	[ContentId] [int] NULL,
	[RenderAsContent] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_CategoryDescription] PRIMARY KEY CLUSTERED 
(
	[CategoryDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_CategoryProductRelation]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_CategoryProductRelation](
	[CategoryProductRelationId] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[CategoryId] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_CategoryProductRelation] PRIMARY KEY CLUSTERED 
(
	[CategoryProductRelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_CategoryProperty]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_CategoryProperty](
	[CategoryPropertyId] [int] IDENTITY(1,1) NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[DefinitionFieldId] [int] NOT NULL,
	[CultureCode] [nvarchar](60) NULL,
	[CategoryId] [int] NOT NULL,
 CONSTRAINT [PK_uCommerce_CategoryProperty] PRIMARY KEY CLUSTERED 
(
	[CategoryPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_CategoryTarget]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_CategoryTarget](
	[CategoryTargetId] [int] NOT NULL,
	[Name] [nvarchar](60) NOT NULL,
 CONSTRAINT [PK_uCommerce_CategoryTarget] PRIMARY KEY CLUSTERED 
(
	[CategoryTargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Country]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Country](
	[CountryId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Culture] [nvarchar](60) NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_Country] PRIMARY KEY CLUSTERED 
(
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Currency]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Currency](
	[CurrencyId] [int] IDENTITY(1,1) NOT NULL,
	[ISOCode] [nvarchar](50) NOT NULL,
	[ExchangeRate] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_Currency] PRIMARY KEY CLUSTERED 
(
	[CurrencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Customer]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Customer](
	[CustomerId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](512) NOT NULL,
	[LastName] [nvarchar](512) NOT NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[MobilePhoneNumber] [nvarchar](50) NULL,
	[MemberId] [nvarchar](255) NULL,
 CONSTRAINT [uCommerce_PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_DataType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_DataType](
	[DataTypeId] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [nvarchar](50) NOT NULL,
	[Nullable] [bit] NOT NULL,
	[ValidationExpression] [nvarchar](512) NOT NULL,
	[BuiltIn] [bit] NOT NULL,
	[DefinitionName] [nvarchar](512) NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_DataType] PRIMARY KEY CLUSTERED 
(
	[DataTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_DataTypeEnum]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_DataTypeEnum](
	[DataTypeEnumId] [int] IDENTITY(1,1) NOT NULL,
	[DataTypeId] [int] NOT NULL,
	[Value] [nvarchar](1024) NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_DataTypeEnum] PRIMARY KEY CLUSTERED 
(
	[DataTypeEnumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_DataTypeEnumDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_DataTypeEnumDescription](
	[DataTypeEnumDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[DataTypeEnumId] [int] NOT NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
	[DisplayName] [nvarchar](512) NOT NULL,
	[Description] [ntext] NULL,
 CONSTRAINT [uCommerce_PK_DataTypeEnumDescription] PRIMARY KEY CLUSTERED 
(
	[DataTypeEnumDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Definition]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Definition](
	[DefinitionId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](512) NOT NULL,
	[DefinitionTypeId] [int] NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_uCommerceDefinition] PRIMARY KEY CLUSTERED 
(
	[DefinitionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_DefinitionField]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_DefinitionField](
	[DefinitionFieldId] [int] IDENTITY(1,1) NOT NULL,
	[DataTypeId] [int] NOT NULL,
	[DefinitionId] [int] NOT NULL,
	[Name] [nvarchar](512) NOT NULL,
	[DisplayOnSite] [bit] NOT NULL,
	[Multilingual] [bit] NOT NULL,
	[RenderInEditor] [bit] NOT NULL,
	[Searchable] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [PK_DefinitionField] PRIMARY KEY CLUSTERED 
(
	[DefinitionFieldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_DefinitionFieldDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_DefinitionFieldDescription](
	[DefinitionFieldDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
	[DisplayName] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[DefinitionFieldId] [int] NOT NULL,
 CONSTRAINT [PK_DefinitionFieldDescription] PRIMARY KEY CLUSTERED 
(
	[DefinitionFieldDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_DefinitionType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_DefinitionType](
	[DefinitionTypeId] [int] NOT NULL,
	[Name] [nvarchar](512) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_uCommerce_DefinitionType] PRIMARY KEY CLUSTERED 
(
	[DefinitionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_DefinitionTypeDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_DefinitionTypeDescription](
	[DefinitionTypeDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[DefinitionTypeId] [int] NOT NULL,
	[DisplayName] [nvarchar](512) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
 CONSTRAINT [PK_DefinitionTypeDescription] PRIMARY KEY CLUSTERED 
(
	[DefinitionTypeDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Discount]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Discount](
	[DiscountId] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [int] NOT NULL,
	[CampaignName] [nvarchar](512) NULL,
	[CampaignItemName] [nvarchar](512) NULL,
	[Description] [nvarchar](512) NULL,
	[AmountOffTotal] [decimal](18, 2) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_uCommerce_Discount] PRIMARY KEY CLUSTERED 
(
	[DiscountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_DiscountSpecificOrderLineAward]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_DiscountSpecificOrderLineAward](
	[DiscountSpecificOrderLineAwardId] [int] NOT NULL,
	[AmountOff] [decimal](18, 2) NOT NULL,
	[AmountType] [int] NOT NULL,
	[DiscountTarget] [int] NOT NULL,
	[Sku] [nvarchar](255) NULL,
	[VariantSku] [nvarchar](255) NULL,
 CONSTRAINT [PK_DiscountSpecificOrderLineAward] PRIMARY KEY CLUSTERED 
(
	[DiscountSpecificOrderLineAwardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_DynamicOrderPropertyTarget]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_DynamicOrderPropertyTarget](
	[DynamicOrderPropertyTargetId] [int] NOT NULL,
	[Key] [nvarchar](255) NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[CompareMode] [int] NOT NULL,
	[TargetOrderLine] [bit] NOT NULL,
 CONSTRAINT [PK_uCommerce_DynamicOrderPropertyTarget] PRIMARY KEY CLUSTERED 
(
	[DynamicOrderPropertyTargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_EmailContent]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_EmailContent](
	[EmailContentId] [int] IDENTITY(1,1) NOT NULL,
	[EmailProfileId] [int] NOT NULL,
	[EmailTypeId] [int] NOT NULL,
	[CultureCode] [nvarchar](50) NOT NULL,
	[Subject] [ntext] NULL,
	[ContentId] [nvarchar](255) NULL,
 CONSTRAINT [uCommerce_PK_EmailContent] PRIMARY KEY CLUSTERED 
(
	[EmailContentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_EmailParameter]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_EmailParameter](
	[EmailParameterId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[GlobalResourceKey] [nvarchar](50) NOT NULL,
	[QueryStringKey] [nvarchar](50) NOT NULL,
 CONSTRAINT [uCommerce_PK_EmailParameter] PRIMARY KEY CLUSTERED 
(
	[EmailParameterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_EmailProfile]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_EmailProfile](
	[EmailProfileId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_EmailProfile] PRIMARY KEY CLUSTERED 
(
	[EmailProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_EmailProfileInformation]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_EmailProfileInformation](
	[EmailProfileInformationId] [int] IDENTITY(1,1) NOT NULL,
	[EmailProfileId] [int] NOT NULL,
	[EmailTypeId] [int] NOT NULL,
	[FromName] [nvarchar](512) NOT NULL,
	[FromAddress] [nvarchar](512) NOT NULL,
	[CcAddress] [nvarchar](512) NULL,
	[BccAddress] [nvarchar](512) NULL,
 CONSTRAINT [uCommerce_PK_EmailProfileInformation] PRIMARY KEY CLUSTERED 
(
	[EmailProfileInformationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_EmailType]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_EmailType](
	[EmailTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Description] [ntext] NULL,
	[CreatedOn] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_EmailType] PRIMARY KEY CLUSTERED 
(
	[EmailTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_EmailTypeParameter]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_EmailTypeParameter](
	[EmailTypeId] [int] NOT NULL,
	[EmailParameterId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_EmailTypeParameter] PRIMARY KEY CLUSTERED 
(
	[EmailTypeId] ASC,
	[EmailParameterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_EntityUi]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_EntityUi](
	[EntityUiId] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](512) NOT NULL,
	[VirtualPathUi] [nvarchar](512) NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_EntityUi] PRIMARY KEY CLUSTERED 
(
	[EntityUiId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_EntityUiDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_EntityUiDescription](
	[EntityUiDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[EntityUiId] [int] NOT NULL,
	[DisplayName] [nvarchar](512) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
 CONSTRAINT [PK_uCommerce_EntityUiDescription] PRIMARY KEY CLUSTERED 
(
	[EntityUiDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_OrderAddress]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_OrderAddress](
	[OrderAddressId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](512) NOT NULL,
	[LastName] [nvarchar](512) NOT NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[MobilePhoneNumber] [nvarchar](50) NULL,
	[Line1] [nvarchar](512) NOT NULL,
	[Line2] [nvarchar](512) NULL,
	[PostalCode] [nvarchar](50) NOT NULL,
	[City] [nvarchar](512) NOT NULL,
	[State] [nvarchar](512) NULL,
	[CountryId] [int] NOT NULL,
	[Attention] [nvarchar](512) NULL,
	[CompanyName] [nvarchar](512) NULL,
	[AddressName] [nvarchar](512) NOT NULL,
	[OrderId] [int] NULL,
 CONSTRAINT [uCommerce_PK_OrderAddress] PRIMARY KEY CLUSTERED 
(
	[OrderAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_OrderAmountTarget]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_OrderAmountTarget](
	[OrderAmountTargetId] [int] NOT NULL,
	[MinAmount] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_OrderAmountTarget] PRIMARY KEY CLUSTERED 
(
	[OrderAmountTargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_OrderLine]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_OrderLine](
	[OrderLineId] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [int] NOT NULL,
	[Sku] [nvarchar](512) NOT NULL,
	[ProductName] [nvarchar](512) NOT NULL,
	[Price] [money] NOT NULL,
	[Quantity] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[Discount] [money] NOT NULL,
	[VAT] [money] NOT NULL,
	[Total] [money] NULL,
	[VATRate] [money] NOT NULL,
	[VariantSku] [nvarchar](512) NULL,
	[ShipmentId] [int] NULL,
	[UnitDiscount] [money] NULL,
	[CreatedBy] [nvarchar](255) NULL,
 CONSTRAINT [uCommerce_PK_OrderLine] PRIMARY KEY CLUSTERED 
(
	[OrderLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_OrderLineDiscountRelation]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_OrderLineDiscountRelation](
	[OrderLineDiscountRelationId] [int] IDENTITY(1,1) NOT NULL,
	[DiscountId] [int] NOT NULL,
	[OrderLineId] [int] NOT NULL,
 CONSTRAINT [PK_uCommerce_OrderLineDiscountRelation] PRIMARY KEY CLUSTERED 
(
	[OrderLineDiscountRelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_OrderNumberSerie]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_OrderNumberSerie](
	[OrderNumberId] [int] IDENTITY(1,1) NOT NULL,
	[OrderNumberName] [nvarchar](128) NOT NULL,
	[Prefix] [nvarchar](50) NULL,
	[Postfix] [nvarchar](50) NULL,
	[Increment] [int] NOT NULL,
	[CurrentNumber] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_OrderNumbers_1] PRIMARY KEY CLUSTERED 
(
	[OrderNumberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_OrderProperty]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_OrderProperty](
	[OrderPropertyId] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [int] NOT NULL,
	[OrderLineId] [int] NULL,
	[Key] [nvarchar](255) NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_uCommerce_OrderProperty] PRIMARY KEY CLUSTERED 
(
	[OrderPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_OrderStatus]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_OrderStatus](
	[OrderStatusId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Sort] [int] NOT NULL,
	[RenderChildren] [bit] NOT NULL,
	[RenderInMenu] [bit] NOT NULL,
	[NextOrderStatusId] [int] NULL,
	[ExternalId] [nvarchar](50) NULL,
	[IncludeInAuditTrail] [bit] NOT NULL,
	[Order] [int] NULL,
	[AllowUpdate] [bit] NOT NULL,
	[AlwaysAvailable] [bit] NOT NULL,
	[Pipeline] [nvarchar](128) NULL,
	[AllowOrderEdit] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_OrderStatus] PRIMARY KEY CLUSTERED 
(
	[OrderStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_OrderStatusAudit]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_OrderStatusAudit](
	[OrderStatusAuditId] [int] IDENTITY(1,1) NOT NULL,
	[NewOrderStatusId] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[OrderId] [int] NOT NULL,
	[Message] [nvarchar](max) NULL,
 CONSTRAINT [uCommerce_PK_OrderStatusAudit] PRIMARY KEY CLUSTERED 
(
	[OrderStatusAuditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_OrderStatusDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_OrderStatusDescription](
	[OrderStatusId] [int] NOT NULL,
	[DisplayName] [nvarchar](128) NOT NULL,
	[Description] [ntext] NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
 CONSTRAINT [uCommerce_PK_OrderStatusDescription] PRIMARY KEY CLUSTERED 
(
	[OrderStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Payment]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Payment](
	[PaymentId] [int] IDENTITY(1,1) NOT NULL,
	[TransactionId] [nvarchar](max) NULL,
	[PaymentMethodName] [nvarchar](50) NOT NULL,
	[Created] [datetime] NOT NULL,
	[PaymentMethodId] [int] NOT NULL,
	[Fee] [money] NOT NULL,
	[FeePercentage] [decimal](18, 4) NOT NULL,
	[PaymentStatusId] [int] NOT NULL,
	[Amount] [money] NOT NULL,
	[OrderId] [int] NOT NULL,
	[FeeTotal] [money] NULL,
	[ReferenceId] [nvarchar](max) NULL,
 CONSTRAINT [uCommerce_PK_Payment] PRIMARY KEY CLUSTERED 
(
	[PaymentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PaymentMethod]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PaymentMethod](
	[PaymentMethodId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[FeePercent] [decimal](18, 4) NOT NULL,
	[ImageMediaId] [nvarchar](255) NULL,
	[PaymentMethodServiceName] [nvarchar](512) NULL,
	[Enabled] [bit] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[Pipeline] [nvarchar](128) NULL,
 CONSTRAINT [uCommerce_PK_PaymentMethod] PRIMARY KEY CLUSTERED 
(
	[PaymentMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PaymentMethodCountry]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PaymentMethodCountry](
	[PaymentMethodId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_PaymentMethodCountry] PRIMARY KEY CLUSTERED 
(
	[PaymentMethodId] ASC,
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PaymentMethodDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PaymentMethodDescription](
	[PaymentMethodDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[PaymentMethodId] [int] NOT NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
	[DisplayName] [nvarchar](512) NOT NULL,
	[Description] [ntext] NULL,
 CONSTRAINT [uCommerce_PK_PaymentMethodDescription] PRIMARY KEY CLUSTERED 
(
	[PaymentMethodDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PaymentMethodFee]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PaymentMethodFee](
	[PaymentMethodFeeId] [int] IDENTITY(1,1) NOT NULL,
	[PaymentMethodId] [int] NOT NULL,
	[CurrencyId] [int] NOT NULL,
	[PriceGroupId] [int] NOT NULL,
	[Fee] [money] NOT NULL,
 CONSTRAINT [uCommerce_PK_PaymentMethodFee] PRIMARY KEY CLUSTERED 
(
	[PaymentMethodFeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PaymentProperty]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PaymentProperty](
	[PaymentPropertyId] [int] IDENTITY(1,1) NOT NULL,
	[PaymentId] [int] NOT NULL,
	[Key] [nvarchar](255) NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_uCommerce_PaymentProperty] PRIMARY KEY CLUSTERED 
(
	[PaymentPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PaymentStatus]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PaymentStatus](
	[PaymentStatusId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [uCommerce_PK_PaymentStatus] PRIMARY KEY CLUSTERED 
(
	[PaymentStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PercentOffOrderLinesAward]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PercentOffOrderLinesAward](
	[PercentOffOrderLinesAwardId] [int] NOT NULL,
	[PercentOff] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_uCommerce_ProcentOffOrderLinesAward] PRIMARY KEY CLUSTERED 
(
	[PercentOffOrderLinesAwardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PercentOffOrderTotalAward]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PercentOffOrderTotalAward](
	[PercentOffOrderTotalAwardId] [int] NOT NULL,
	[PercentOff] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_PercentOffOrderTotalAward] PRIMARY KEY CLUSTERED 
(
	[PercentOffOrderTotalAwardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PercentOffShippingTotalAward]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PercentOffShippingTotalAward](
	[PercentOffShippingTotalAwardId] [int] NOT NULL,
	[PercentOff] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_uCommerce_PercentOffShippingAward] PRIMARY KEY CLUSTERED 
(
	[PercentOffShippingTotalAwardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Permission]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Permission](
	[PermissionId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[RoleId] [int] NULL,
 CONSTRAINT [uCommerce_PK_Permission] PRIMARY KEY CLUSTERED 
(
	[PermissionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PriceGroup]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PriceGroup](
	[PriceGroupId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[CurrencyId] [int] NOT NULL,
	[VATRate] [decimal](18, 4) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedOn] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_PriceGroup] PRIMARY KEY CLUSTERED 
(
	[PriceGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PriceGroupPrice]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PriceGroupPrice](
	[PriceGroupPriceId] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[Price] [money] NULL,
	[DiscountPrice] [money] NULL,
	[PriceGroupId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_PriceGroupPrice] PRIMARY KEY CLUSTERED 
(
	[PriceGroupPriceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Product]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Product](
	[ProductId] [int] IDENTITY(1,1) NOT NULL,
	[ParentProductId] [int] NULL,
	[Sku] [nvarchar](30) NOT NULL,
	[VariantSku] [nvarchar](30) NULL,
	[Name] [nvarchar](512) NOT NULL,
	[DisplayOnSite] [bit] NOT NULL,
	[ThumbnailImageMediaId] [nvarchar](100) NULL,
	[PrimaryImageMediaId] [nvarchar](100) NULL,
	[Weight] [decimal](18, 4) NOT NULL,
	[ProductDefinitionId] [int] NOT NULL,
	[AllowOrdering] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[Rating] [float] NULL,
 CONSTRAINT [uCommerce_PK_Product] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductCatalog]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductCatalog](
	[ProductCatalogId] [int] IDENTITY(1,1) NOT NULL,
	[ProductCatalogGroupId] [int] NOT NULL,
	[Name] [nvarchar](60) NOT NULL,
	[PriceGroupId] [int] NOT NULL,
	[ShowPricesIncludingVAT] [bit] NOT NULL,
	[IsVirtual] [bit] NOT NULL,
	[DisplayOnWebSite] [bit] NOT NULL,
	[LimitedAccess] [bit] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](512) NOT NULL,
	[ModifiedBy] [nvarchar](512) NOT NULL,
 CONSTRAINT [uCommerce_PK_Catalog] PRIMARY KEY CLUSTERED 
(
	[ProductCatalogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductCatalogDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductCatalogDescription](
	[ProductCatalogDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[ProductCatalogId] [int] NOT NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
	[DisplayName] [nvarchar](512) NOT NULL,
 CONSTRAINT [uCommerce_PK_ProductCatalogDescription] PRIMARY KEY CLUSTERED 
(
	[ProductCatalogDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductCatalogGroup]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductCatalogGroup](
	[ProductCatalogGroupId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Description] [ntext] NULL,
	[EmailProfileId] [int] NOT NULL,
	[CurrencyId] [int] NOT NULL,
	[DomainId] [nvarchar](255) NULL,
	[OrderNumberId] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[CreateCustomersAsUmbracoMembers] [bit] NOT NULL,
	[MemberGroupId] [nvarchar](255) NULL,
	[MemberTypeId] [nvarchar](255) NULL,
	[ProductReviewsRequireApproval] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_CatalogGroup] PRIMARY KEY CLUSTERED 
(
	[ProductCatalogGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductCatalogGroupCampaignRelation]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductCatalogGroupCampaignRelation](
	[ProductCatalogGroupCampaignRelationId] [int] IDENTITY(1,1) NOT NULL,
	[CampaignId] [int] NULL,
	[ProductCatalogGroupId] [int] NULL,
 CONSTRAINT [uCommerce_PK_ProductCatalogGroupCampaignRelation] PRIMARY KEY CLUSTERED 
(
	[ProductCatalogGroupCampaignRelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductCatalogGroupPaymentMethodMap]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductCatalogGroupPaymentMethodMap](
	[ProductCatalogGroupId] [int] NOT NULL,
	[PaymentMethodId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_ProductCatalogGroupPaymentMethodMap] PRIMARY KEY CLUSTERED 
(
	[ProductCatalogGroupId] ASC,
	[PaymentMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductCatalogGroupShippingMethodMap]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductCatalogGroupShippingMethodMap](
	[ProductCatalogGroupId] [int] NOT NULL,
	[ShippingMethodId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_ProductCatalogGroupShippingMethodMap] PRIMARY KEY CLUSTERED 
(
	[ProductCatalogGroupId] ASC,
	[ShippingMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductCatalogGroupTarget]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductCatalogGroupTarget](
	[ProductCatalogGroupTargetId] [int] NOT NULL,
	[Name] [nvarchar](60) NOT NULL,
 CONSTRAINT [PK_uCommerce_ProductCatalogGroupTarget] PRIMARY KEY CLUSTERED 
(
	[ProductCatalogGroupTargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductCatalogTarget]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductCatalogTarget](
	[ProductCatalogTargetId] [int] NOT NULL,
	[Name] [nvarchar](60) NOT NULL,
 CONSTRAINT [PK_ProductCatalogTarget] PRIMARY KEY CLUSTERED 
(
	[ProductCatalogTargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductDefinition]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductDefinition](
	[ProductDefinitionId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](512) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Deleted] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_ProductDefinition] PRIMARY KEY CLUSTERED 
(
	[ProductDefinitionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductDefinitionField]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductDefinitionField](
	[ProductDefinitionFieldId] [int] IDENTITY(1,1) NOT NULL,
	[DataTypeId] [int] NOT NULL,
	[ProductDefinitionId] [int] NOT NULL,
	[Name] [nvarchar](512) NOT NULL,
	[DisplayOnSite] [bit] NOT NULL,
	[IsVariantProperty] [bit] NOT NULL,
	[Multilingual] [bit] NOT NULL,
	[RenderInEditor] [bit] NOT NULL,
	[Searchable] [bit] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_ProductDefinitionField] PRIMARY KEY CLUSTERED 
(
	[ProductDefinitionFieldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductDefinitionFieldDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductDefinitionFieldDescription](
	[ProductDefinitionFieldDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
	[DisplayName] [nvarchar](255) NOT NULL,
	[ProductDefinitionFieldId] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [uCommerce_PK_ProductDefinitionFieldDescription] PRIMARY KEY CLUSTERED 
(
	[ProductDefinitionFieldDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductDescription]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductDescription](
	[ProductDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[DisplayName] [nvarchar](512) NOT NULL,
	[ShortDescription] [nvarchar](max) NULL,
	[LongDescription] [nvarchar](max) NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
 CONSTRAINT [uCommerce_PK_ProductDescription] PRIMARY KEY CLUSTERED 
(
	[ProductDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_uCommerce_ProductDescription_ProductId_CultureCode] UNIQUE NONCLUSTERED 
(
	[ProductId] ASC,
	[CultureCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductDescriptionProperty]    Script Date: 22-05-2013 09:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductDescriptionProperty](
	[ProductDescriptionPropertyId] [int] IDENTITY(1,1) NOT NULL,
	[ProductDescriptionId] [int] NOT NULL,
	[ProductDefinitionFieldId] [int] NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [uCommerce_PK_ProductDescriptionProperty] PRIMARY KEY CLUSTERED 
(
	[ProductDescriptionPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductProperty]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductProperty](
	[ProductPropertyId] [int] IDENTITY(1,1) NOT NULL,
	[Value] [nvarchar](max) NULL,
	[ProductDefinitionFieldId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_ProductProperty] PRIMARY KEY CLUSTERED 
(
	[ProductPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductRelation]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductRelation](
	[ProductRelationId] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[RelatedProductId] [int] NOT NULL,
	[ProductRelationTypeId] [int] NOT NULL,
 CONSTRAINT [PK_uCommerce_ProductRelation2] PRIMARY KEY CLUSTERED 
(
	[ProductRelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductRelationType]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductRelationType](
	[ProductRelationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedOn] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_uCommerce_ProductRelation] PRIMARY KEY CLUSTERED 
(
	[ProductRelationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductReview]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductReview](
	[ProductReviewId] [int] IDENTITY(1,1) NOT NULL,
	[Rating] [int] NULL,
	[CustomerId] [int] NULL,
	[ProductCatalogGroupId] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[CultureCode] [nvarchar](60) NULL,
	[ReviewHeadline] [nvarchar](512) NULL,
	[ReviewText] [nvarchar](max) NULL,
	[ProductId] [int] NOT NULL,
	[Ip] [nvarchar](50) NOT NULL,
	[ProductReviewStatusId] [int] NOT NULL,
 CONSTRAINT [PK_uCommerce_ProductReview] PRIMARY KEY CLUSTERED 
(
	[ProductReviewId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductReviewComment]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductReviewComment](
	[ProductReviewCommentId] [int] IDENTITY(1,1) NOT NULL,
	[ProductReviewId] [int] NOT NULL,
	[CustomerId] [int] NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[CultureCode] [nvarchar](60) NULL,
	[Comment] [nvarchar](max) NULL,
	[Helpful] [bit] NOT NULL,
	[Unhelpful] [bit] NOT NULL,
	[Ip] [nvarchar](50) NOT NULL,
	[ProductReviewStatusId] [int] NOT NULL,
 CONSTRAINT [PK_uCommerce_ProductReviewComment] PRIMARY KEY CLUSTERED 
(
	[ProductReviewCommentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductReviewStatus]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductReviewStatus](
	[ProductReviewStatusId] [int] NOT NULL,
	[Name] [nvarchar](1024) NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [PK_uCommerce_ProductReviewStatus] PRIMARY KEY CLUSTERED 
(
	[ProductReviewStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ProductTarget]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ProductTarget](
	[ProductTargetId] [int] NOT NULL,
	[Sku] [nvarchar](30) NOT NULL,
	[VariantSku] [nvarchar](30) NULL,
 CONSTRAINT [PK_uCommerce_ProductTarget] PRIMARY KEY CLUSTERED 
(
	[ProductTargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_PurchaseOrder]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_PurchaseOrder](
	[OrderId] [int] IDENTITY(1,1) NOT NULL,
	[OrderNumber] [nvarchar](50) NULL,
	[CustomerId] [int] NULL,
	[OrderStatusId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CompletedDate] [datetime] NULL,
	[CurrencyId] [int] NOT NULL,
	[ProductCatalogGroupId] [int] NOT NULL,
	[BillingAddressId] [int] NULL,
	[Note] [ntext] NULL,
	[BasketId] [uniqueidentifier] NOT NULL,
	[VAT] [money] NULL,
	[OrderTotal] [money] NULL,
	[ShippingTotal] [money] NULL,
	[PaymentTotal] [money] NULL,
	[TaxTotal] [money] NULL,
	[SubTotal] [money] NULL,
	[OrderGuid] [uniqueidentifier] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[CultureCode] [nvarchar](60) NULL,
	[Discount] [money] NULL,
	[DiscountTotal] [money] NULL,
 CONSTRAINT [uCommerce_PK_Order] PRIMARY KEY CLUSTERED 
(
	[OrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_QuantityTarget]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_QuantityTarget](
	[QuantityTargetId] [int] NOT NULL,
	[MinQuantity] [int] NOT NULL,
 CONSTRAINT [PK_uCommerce_QuantityTarget] PRIMARY KEY CLUSTERED 
(
	[QuantityTargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Role]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Role](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[ProductCatalogGroupId] [int] NULL,
	[ProductCatalogId] [int] NULL,
	[CultureCode] [nvarchar](10) NULL,
	[PriceGroupId] [int] NULL,
	[RoleType] [int] NOT NULL,
	[ParentRoleId] [int] NULL,
 CONSTRAINT [uCommerce_PK_Role] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Shipment]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Shipment](
	[ShipmentId] [int] IDENTITY(1,1) NOT NULL,
	[ShipmentName] [nvarchar](128) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ShipmentPrice] [money] NOT NULL,
	[ShippingMethodId] [int] NOT NULL,
	[ShipmentAddressId] [int] NULL,
	[DeliveryNote] [ntext] NULL,
	[OrderId] [int] NOT NULL,
	[TrackAndTrace] [nvarchar](512) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[Tax] [money] NOT NULL,
	[TaxRate] [money] NOT NULL,
	[ShipmentTotal] [money] NOT NULL,
	[ShipmentDiscount] [money] NULL,
 CONSTRAINT [uCommerce_PK_Shipping] PRIMARY KEY CLUSTERED 
(
	[ShipmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ShipmentDiscountRelation]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ShipmentDiscountRelation](
	[ShipmentDiscountRelationId] [int] IDENTITY(1,1) NOT NULL,
	[ShipmentId] [int] NOT NULL,
	[DiscountId] [int] NOT NULL,
 CONSTRAINT [PK_uCommerce_ShipmentDiscountRelation] PRIMARY KEY CLUSTERED 
(
	[ShipmentDiscountRelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ShippingMethod]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ShippingMethod](
	[ShippingMethodId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[ImageMediaId] [nvarchar](255) NULL,
	[PaymentMethodId] [int] NULL,
	[ServiceName] [nvarchar](128) NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [uCommerce_PK_ShippingMethod] PRIMARY KEY CLUSTERED 
(
	[ShippingMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ShippingMethodCountry]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ShippingMethodCountry](
	[ShippingMethodId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_ShippingMethodCountry] PRIMARY KEY CLUSTERED 
(
	[ShippingMethodId] ASC,
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ShippingMethodDescription]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ShippingMethodDescription](
	[ShippingMethodDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[ShippingMethodId] [int] NOT NULL,
	[DisplayName] [nvarchar](128) NOT NULL,
	[Description] [nvarchar](512) NULL,
	[DeliveryText] [nvarchar](512) NULL,
	[CultureCode] [nvarchar](60) NOT NULL,
 CONSTRAINT [uCommerce_PK_ShippingMethodDescription] PRIMARY KEY CLUSTERED 
(
	[ShippingMethodDescriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ShippingMethodPaymentMethods]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ShippingMethodPaymentMethods](
	[ShippingMethodId] [int] NOT NULL,
	[PaymentMethodId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_ShippingMethodPaymentMethods] PRIMARY KEY CLUSTERED 
(
	[ShippingMethodId] ASC,
	[PaymentMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_ShippingMethodPrice]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_ShippingMethodPrice](
	[ShippingMethodPriceId] [int] IDENTITY(1,1) NOT NULL,
	[ShippingMethodId] [int] NOT NULL,
	[PriceGroupId] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[CurrencyId] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_ShippingMethodPrice] PRIMARY KEY CLUSTERED 
(
	[ShippingMethodPriceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_SystemVersion]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_SystemVersion](
	[SystemVersionId] [int] IDENTITY(1,1) NOT NULL,
	[SchemaVersion] [int] NOT NULL,
 CONSTRAINT [uCommerce_PK_SystemVersion] PRIMARY KEY CLUSTERED 
(
	[SystemVersionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_Target]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_Target](
	[TargetId] [int] IDENTITY(1,1) NOT NULL,
	[CampaignItemId] [int] NOT NULL,
	[EnabledForDisplay] [bit] NOT NULL,
	[EnabledForApply] [bit] NOT NULL,
 CONSTRAINT [PK_uCommerce_Target] PRIMARY KEY CLUSTERED 
(
	[TargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_User]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_User](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[ExternalId] [nvarchar](255) NULL,
 CONSTRAINT [uCommerce_PK_User] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_VoucherCode]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_VoucherCode](
	[VoucherCodeId] [int] IDENTITY(1,1) NOT NULL,
	[TargetId] [int] NOT NULL,
	[NumberUsed] [int] NOT NULL,
	[MaxUses] [int] NOT NULL,
	[Code] [nvarchar](512) NOT NULL,
 CONSTRAINT [PK_uCommerce_VoucherCode_1] PRIMARY KEY CLUSTERED 
(
	[VoucherCodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[uCommerce_VoucherTarget]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uCommerce_VoucherTarget](
	[VoucherTargetId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_uCommerce_SingleUseVoucher_1] PRIMARY KEY CLUSTERED 
(
	[VoucherTargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoDomains]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoDomains](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[domainDefaultLanguage] [int] NULL,
	[domainRootStructureID] [int] NULL,
	[domainName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_umbracoDomains] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoLanguage]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoLanguage](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[languageISOCode] [nvarchar](10) NULL,
	[languageCultureName] [nvarchar](100) NULL,
 CONSTRAINT [PK_umbracoLanguage] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoLog]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NOT NULL,
	[NodeId] [int] NOT NULL,
	[Datestamp] [datetime] NOT NULL,
	[logHeader] [nvarchar](50) NOT NULL,
	[logComment] [nvarchar](4000) NULL,
 CONSTRAINT [PK_umbracoLog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoNode]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoNode](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[trashed] [bit] NOT NULL,
	[parentID] [int] NOT NULL,
	[nodeUser] [int] NULL,
	[level] [int] NOT NULL,
	[path] [nvarchar](150) NOT NULL,
	[sortOrder] [int] NOT NULL,
	[uniqueID] [uniqueidentifier] NULL,
	[text] [nvarchar](255) NULL,
	[nodeObjectType] [uniqueidentifier] NULL,
	[createDate] [datetime] NOT NULL,
 CONSTRAINT [PK_structure] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoRelation]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoRelation](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[parentId] [int] NOT NULL,
	[childId] [int] NOT NULL,
	[relType] [int] NOT NULL,
	[datetime] [datetime] NOT NULL,
	[comment] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_umbracoRelation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoRelationType]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoRelationType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dual] [bit] NOT NULL,
	[parentObjectType] [uniqueidentifier] NOT NULL,
	[childObjectType] [uniqueidentifier] NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[alias] [nvarchar](100) NULL,
 CONSTRAINT [PK_umbracoRelationType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoUser]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoUser](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userDisabled] [bit] NOT NULL,
	[userNoConsole] [bit] NOT NULL,
	[userType] [int] NOT NULL,
	[startStructureID] [int] NOT NULL,
	[startMediaID] [int] NULL,
	[userName] [nvarchar](255) NOT NULL,
	[userLogin] [nvarchar](125) NOT NULL,
	[userPassword] [nvarchar](125) NOT NULL,
	[userEmail] [nvarchar](255) NOT NULL,
	[userDefaultPermissions] [nvarchar](50) NULL,
	[userLanguage] [nvarchar](10) NULL,
	[defaultToLiveEditing] [bit] NOT NULL,
 CONSTRAINT [PK_user] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoUser2app]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoUser2app](
	[user] [int] NOT NULL,
	[app] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_user2app] PRIMARY KEY CLUSTERED 
(
	[user] ASC,
	[app] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoUser2NodeNotify]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoUser2NodeNotify](
	[userId] [int] NOT NULL,
	[nodeId] [int] NOT NULL,
	[action] [nchar](1) NOT NULL,
 CONSTRAINT [PK_umbracoUser2NodeNotify] PRIMARY KEY CLUSTERED 
(
	[userId] ASC,
	[nodeId] ASC,
	[action] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoUser2NodePermission]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoUser2NodePermission](
	[userId] [int] NOT NULL,
	[nodeId] [int] NOT NULL,
	[permission] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_umbracoUser2NodePermission] PRIMARY KEY CLUSTERED 
(
	[userId] ASC,
	[nodeId] ASC,
	[permission] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoUserLogins]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoUserLogins](
	[contextID] [uniqueidentifier] NOT NULL,
	[userID] [int] NOT NULL,
	[timeout] [bigint] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[umbracoUserType]    Script Date: 22-05-2013 09:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[umbracoUserType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userTypeAlias] [nvarchar](50) NULL,
	[userTypeName] [nvarchar](255) NOT NULL,
	[userTypeDefaultPermissions] [nvarchar](50) NULL,
 CONSTRAINT [PK_umbracoUserType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [umbracoUserLogins_Index]    Script Date: 22-05-2013 09:38:53 ******/
CREATE CLUSTERED INDEX [umbracoUserLogins_Index] ON [dbo].[umbracoUserLogins]
(
	[contextID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsContent]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cmsContent] ON [dbo].[cmsContent]
(
	[nodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsContentType]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cmsContentType] ON [dbo].[cmsContentType]
(
	[nodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_cmsContentType_icon]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_cmsContentType_icon] ON [dbo].[cmsContentType]
(
	[icon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsContentVersion_VersionId]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cmsContentVersion_VersionId] ON [dbo].[cmsContentVersion]
(
	[VersionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsDataType_nodeId]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cmsDataType_nodeId] ON [dbo].[cmsDataType]
(
	[nodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsDictionary_id]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cmsDictionary_id] ON [dbo].[cmsDictionary]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsDocument]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cmsDocument] ON [dbo].[cmsDocument]
(
	[nodeId] ASC,
	[versionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsPropertyData]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_cmsPropertyData] ON [dbo].[cmsPropertyData]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsPropertyData_1]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_cmsPropertyData_1] ON [dbo].[cmsPropertyData]
(
	[contentNodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsPropertyData_2]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_cmsPropertyData_2] ON [dbo].[cmsPropertyData]
(
	[versionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsPropertyData_3]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_cmsPropertyData_3] ON [dbo].[cmsPropertyData]
(
	[propertytypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_cmsTaskType_alias]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_cmsTaskType_alias] ON [dbo].[cmsTaskType]
(
	[alias] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cmsTemplate_nodeId]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cmsTemplate_nodeId] ON [dbo].[cmsTemplate]
(
	[nodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_AdminPage]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_AdminPage] ON [dbo].[uCommerce_AdminPage]
(
	[FullName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_Campaign]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_uCommerce_Campaign] ON [dbo].[uCommerce_Campaign]
(
	[CampaignId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Category]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_Category] ON [dbo].[uCommerce_Category]
(
	[Name] ASC,
	[ProductCatalogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CategoryProductRelation]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_CategoryProductRelation] ON [dbo].[uCommerce_CategoryProductRelation]
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_Definition]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_uCommerce_Definition] ON [dbo].[uCommerce_Definition]
(
	[DefinitionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_EntityUi_Type]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_uCommerce_EntityUi_Type] ON [dbo].[uCommerce_EntityUi]
(
	[EntityUiId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_OrderNumbers]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_OrderNumbers] ON [dbo].[uCommerce_OrderNumberSerie]
(
	[OrderNumberName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_uCommerce_OrderProperty]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_uCommerce_OrderProperty] ON [dbo].[uCommerce_OrderProperty]
(
	[Key] ASC,
	[OrderId] ASC,
	[OrderLineId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_PriceGroupPrice_ProductId]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_uCommerce_PriceGroupPrice_ProductId] ON [dbo].[uCommerce_PriceGroupPrice]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Product_UniqueSkuAndVariantSku]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Product_UniqueSkuAndVariantSku] ON [dbo].[uCommerce_Product]
(
	[Sku] ASC,
	[VariantSku] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_Product_ParentProductId]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_uCommerce_Product_ParentProductId] ON [dbo].[uCommerce_Product]
(
	[ParentProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ProductCatalog_UniqueName]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductCatalog_UniqueName] ON [dbo].[uCommerce_ProductCatalog]
(
	[Name] ASC,
	[ProductCatalogGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_ProductDescription_ProductId]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_uCommerce_ProductDescription_ProductId] ON [dbo].[uCommerce_ProductDescription]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_ProductProperty_ProductId]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_uCommerce_ProductProperty_ProductId] ON [dbo].[uCommerce_ProductProperty]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_ProductRelation]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_uCommerce_ProductRelation] ON [dbo].[uCommerce_ProductRelation]
(
	[ProductId] ASC,
	[RelatedProductId] ASC,
	[ProductRelationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_ProductReview]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_uCommerce_ProductReview] ON [dbo].[uCommerce_ProductReview]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Order]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_Order] ON [dbo].[uCommerce_PurchaseOrder]
(
	[OrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_uCommerce_PurchaseOrder_BasketId]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_uCommerce_PurchaseOrder_BasketId] ON [dbo].[uCommerce_PurchaseOrder]
(
	[BasketId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_umbracoLanguage_languageISOCode]    Script Date: 22-05-2013 09:38:53 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_umbracoLanguage_languageISOCode] ON [dbo].[umbracoLanguage]
(
	[languageISOCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_umbracoLog]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_umbracoLog] ON [dbo].[umbracoLog]
(
	[NodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_umbracoNodeObjectType]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_umbracoNodeObjectType] ON [dbo].[umbracoNode]
(
	[nodeObjectType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_umbracoNodeParentId]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_umbracoNodeParentId] ON [dbo].[umbracoNode]
(
	[parentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_umbracoUser_userLogin]    Script Date: 22-05-2013 09:38:53 ******/
CREATE NONCLUSTERED INDEX [IX_umbracoUser_userLogin] ON [dbo].[umbracoUser]
(
	[userLogin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cmsContentType] ADD  CONSTRAINT [DF_cmsContentType_thumbnail]  DEFAULT ('folder.png') FOR [thumbnail]
GO
ALTER TABLE [dbo].[cmsContentType] ADD  CONSTRAINT [DF_cmsContentType_isContainer]  DEFAULT ('0') FOR [isContainer]
GO
ALTER TABLE [dbo].[cmsContentType] ADD  CONSTRAINT [DF_cmsContentType_allowAtRoot]  DEFAULT ('0') FOR [allowAtRoot]
GO
ALTER TABLE [dbo].[cmsContentTypeAllowedContentType] ADD  CONSTRAINT [df_cmsContentTypeAllowedContentType_sortOrder]  DEFAULT ('0') FOR [SortOrder]
GO
ALTER TABLE [dbo].[cmsContentVersion] ADD  CONSTRAINT [DF_cmsContentVersion_VersionDate]  DEFAULT (getdate()) FOR [VersionDate]
GO
ALTER TABLE [dbo].[cmsDocument] ADD  CONSTRAINT [DF_cmsDocument_updateDate]  DEFAULT (getdate()) FOR [updateDate]
GO
ALTER TABLE [dbo].[cmsDocument] ADD  CONSTRAINT [DF_cmsDocument_newest]  DEFAULT ('0') FOR [newest]
GO
ALTER TABLE [dbo].[cmsDocumentType] ADD  CONSTRAINT [DF_cmsDocumentType_IsDefault]  DEFAULT ('0') FOR [IsDefault]
GO
ALTER TABLE [dbo].[cmsMacro] ADD  CONSTRAINT [DF_cmsMacro_macroUseInEditor]  DEFAULT ('0') FOR [macroUseInEditor]
GO
ALTER TABLE [dbo].[cmsMacro] ADD  CONSTRAINT [DF_cmsMacro_macroRefreshRate]  DEFAULT ('0') FOR [macroRefreshRate]
GO
ALTER TABLE [dbo].[cmsMacro] ADD  CONSTRAINT [DF_cmsMacro_macroCacheByPage]  DEFAULT ('1') FOR [macroCacheByPage]
GO
ALTER TABLE [dbo].[cmsMacro] ADD  CONSTRAINT [DF_cmsMacro_macroCachePersonalized]  DEFAULT ('0') FOR [macroCachePersonalized]
GO
ALTER TABLE [dbo].[cmsMacro] ADD  CONSTRAINT [DF_cmsMacro_macroDontRender]  DEFAULT ('0') FOR [macroDontRender]
GO
ALTER TABLE [dbo].[cmsMacroProperty] ADD  CONSTRAINT [DF_cmsMacroProperty_macroPropertyHidden]  DEFAULT ('0') FOR [macroPropertyHidden]
GO
ALTER TABLE [dbo].[cmsMacroProperty] ADD  CONSTRAINT [DF_cmsMacroProperty_macroPropertySortOrder]  DEFAULT ('0') FOR [macroPropertySortOrder]
GO
ALTER TABLE [dbo].[cmsMember] ADD  CONSTRAINT [DF_cmsMember_Email]  DEFAULT ('''') FOR [Email]
GO
ALTER TABLE [dbo].[cmsMember] ADD  CONSTRAINT [DF_cmsMember_LoginName]  DEFAULT ('''') FOR [LoginName]
GO
ALTER TABLE [dbo].[cmsMember] ADD  CONSTRAINT [DF_cmsMember_Password]  DEFAULT ('''') FOR [Password]
GO
ALTER TABLE [dbo].[cmsMemberType] ADD  CONSTRAINT [DF_cmsMemberType_memberCanEdit]  DEFAULT ('0') FOR [memberCanEdit]
GO
ALTER TABLE [dbo].[cmsMemberType] ADD  CONSTRAINT [DF_cmsMemberType_viewOnProfile]  DEFAULT ('0') FOR [viewOnProfile]
GO
ALTER TABLE [dbo].[cmsPropertyType] ADD  CONSTRAINT [DF_cmsPropertyType_sortOrder]  DEFAULT ('0') FOR [sortOrder]
GO
ALTER TABLE [dbo].[cmsPropertyType] ADD  CONSTRAINT [DF_cmsPropertyType_mandatory]  DEFAULT ('0') FOR [mandatory]
GO
ALTER TABLE [dbo].[cmsTask] ADD  CONSTRAINT [DF_cmsTask_closed]  DEFAULT ('0') FOR [closed]
GO
ALTER TABLE [dbo].[cmsTask] ADD  CONSTRAINT [DF_cmsTask_DateTime]  DEFAULT (getdate()) FOR [DateTime]
GO
ALTER TABLE [dbo].[uCommerce_AdminPage] ADD  CONSTRAINT [uCommerce_AdminPage_ActiveTab]  DEFAULT ('') FOR [ActiveTab]
GO
ALTER TABLE [dbo].[uCommerce_AdminTab] ADD  CONSTRAINT [uCommerce_DF_AdminTab_MultiLingual]  DEFAULT ((0)) FOR [MultiLingual]
GO
ALTER TABLE [dbo].[uCommerce_AdminTab] ADD  CONSTRAINT [uCommerce_DF_AdminTab_HasSaveButton]  DEFAULT ((1)) FOR [HasSaveButton]
GO
ALTER TABLE [dbo].[uCommerce_AdminTab] ADD  CONSTRAINT [uCommerce_DF_AdminTab_HasDeleteButton]  DEFAULT ((0)) FOR [HasDeleteButton]
GO
ALTER TABLE [dbo].[uCommerce_Category] ADD  CONSTRAINT [uCommerce_DF_Category_DisplayOnSite]  DEFAULT ((1)) FOR [DisplayOnSite]
GO
ALTER TABLE [dbo].[uCommerce_Category] ADD  CONSTRAINT [uCommerce_DF_Category_CreatedDate]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[uCommerce_Category] ADD  CONSTRAINT [uCommerce_DF_Category_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_Category] ADD  CONSTRAINT [DF_uCommerce_Category_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[uCommerce_Category] ADD  CONSTRAINT [DF_uCommerce_Category_DefinitionId]  DEFAULT ((1)) FOR [DefinitionId]
GO
ALTER TABLE [dbo].[uCommerce_CategoryDescription] ADD  CONSTRAINT [uCommerce_DF_CategoryDescription_RenderAsContent]  DEFAULT ((0)) FOR [RenderAsContent]
GO
ALTER TABLE [dbo].[uCommerce_CategoryProductRelation] ADD  CONSTRAINT [DF_uCommerce_CategoryProductRelation_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[uCommerce_Country] ADD  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_Currency] ADD  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_DataType] ADD  CONSTRAINT [uCommerce_DF_DataType_BuiltIn]  DEFAULT ((0)) FOR [BuiltIn]
GO
ALTER TABLE [dbo].[uCommerce_DataType] ADD  CONSTRAINT [DF__uCommerce__Delet__4A4E069C]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_DataTypeEnum] ADD  CONSTRAINT [DF__uCommerce__Delet__4959E263]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_Definition] ADD  CONSTRAINT [DF_uCommerce_Definition_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[uCommerce_DefinitionField] ADD  CONSTRAINT [DF_uCommerce_DefinitionField_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[uCommerce_DefinitionType] ADD  CONSTRAINT [DF_uCommerce_DefinitionType_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[uCommerce_DynamicOrderPropertyTarget] ADD  CONSTRAINT [DF_uCommerce_DynamicOrderPropertyTarget_TargetOrderLine]  DEFAULT ((0)) FOR [TargetOrderLine]
GO
ALTER TABLE [dbo].[uCommerce_EmailProfile] ADD  CONSTRAINT [uCommerce_DF_EmailProfile_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_EmailType] ADD  CONSTRAINT [uCommerce_DF_EmailType_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_OrderLine] ADD  CONSTRAINT [uCommerce_DF_OrderLine_CreatedDate]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[uCommerce_OrderLine] ADD  CONSTRAINT [uCommerce_DF_OrderLine_Rebate]  DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE [dbo].[uCommerce_OrderLine] ADD  CONSTRAINT [uCommerce_DF_OrderLine_Vat]  DEFAULT ((0)) FOR [VAT]
GO
ALTER TABLE [dbo].[uCommerce_OrderNumberSerie] ADD  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatus] ADD  CONSTRAINT [uCommerce_DF_OrderStatus_Sort]  DEFAULT ((0)) FOR [Sort]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatus] ADD  CONSTRAINT [uCommerce_DF_OrderStatus_RenderChildren]  DEFAULT ((0)) FOR [RenderChildren]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatus] ADD  CONSTRAINT [uCommerce_DF_OrderStatus_RenderInMenu]  DEFAULT ((1)) FOR [RenderInMenu]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatus] ADD  CONSTRAINT [uCommerce_DF_OrderStatus_IncludeInAuditTrail]  DEFAULT ((1)) FOR [IncludeInAuditTrail]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatus] ADD  CONSTRAINT [uCommerce_DF_OrderStatus_AllowUpdate]  DEFAULT ((1)) FOR [AllowUpdate]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatus] ADD  CONSTRAINT [uCommerce_DF_OrderStatus_AlwaysAvailable]  DEFAULT ((0)) FOR [AlwaysAvailable]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatus] ADD  CONSTRAINT [uCommerce_OrderStatus_AllowOrderEdit]  DEFAULT ((0)) FOR [AllowOrderEdit]
GO
ALTER TABLE [dbo].[uCommerce_Payment] ADD  CONSTRAINT [uCommerce_DF_Payment_Created]  DEFAULT (getdate()) FOR [Created]
GO
ALTER TABLE [dbo].[uCommerce_Payment] ADD  CONSTRAINT [uCommerce_DF_Payment_Fee]  DEFAULT ((0)) FOR [Fee]
GO
ALTER TABLE [dbo].[uCommerce_Payment] ADD  CONSTRAINT [uCommerce_DF_Payment_FeePercentage]  DEFAULT ((0)) FOR [FeePercentage]
GO
ALTER TABLE [dbo].[uCommerce_Payment] ADD  DEFAULT ((0)) FOR [FeeTotal]
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethod] ADD  CONSTRAINT [uCommerce_DF_Table_1_FeePercant]  DEFAULT ((0)) FOR [FeePercent]
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethod] ADD  CONSTRAINT [uCommerce_DF_PaymentMethod_Enabled]  DEFAULT ((1)) FOR [Enabled]
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethod] ADD  CONSTRAINT [uCommerce_DF_PaymentMethod_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_PriceGroup] ADD  CONSTRAINT [uCommerce_DF_PriceGroup_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[uCommerce_PriceGroup] ADD  CONSTRAINT [uCommerce_DF_PriceGroup_ModifiedOn]  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[uCommerce_PriceGroup] ADD  CONSTRAINT [uCommerce_DF_PriceGroup_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_Product] ADD  CONSTRAINT [uCommerce_DF_Product_DisplayOnSite]  DEFAULT ((1)) FOR [DisplayOnSite]
GO
ALTER TABLE [dbo].[uCommerce_Product] ADD  CONSTRAINT [uCommerce_DF_Product_Weight]  DEFAULT ((0)) FOR [Weight]
GO
ALTER TABLE [dbo].[uCommerce_Product] ADD  CONSTRAINT [uCommerce_DF_Product_AllowOrdering]  DEFAULT ((1)) FOR [AllowOrdering]
GO
ALTER TABLE [dbo].[uCommerce_Product] ADD  CONSTRAINT [uCommerce_DF_Product_LastModified]  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[uCommerce_Product] ADD  CONSTRAINT [uCommerce_DF_Product_CreatedDate]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[uCommerce_Product] ADD  CONSTRAINT [DF_uCommerce_Product_AverageRating]  DEFAULT ((0)) FOR [Rating]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] ADD  CONSTRAINT [uCommerce_DF_Catalog_ShowPricesIncludingVAT]  DEFAULT ((1)) FOR [ShowPricesIncludingVAT]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] ADD  CONSTRAINT [uCommerce_DF_ProductCatalog_IsVirtual]  DEFAULT ((0)) FOR [IsVirtual]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] ADD  CONSTRAINT [uCommerce_DF_ProductCatalog_DisplayOnWebSite]  DEFAULT ((0)) FOR [DisplayOnWebSite]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] ADD  CONSTRAINT [uCommerce_DF_ProductCatalog_LimitedAccess]  DEFAULT ((0)) FOR [LimitedAccess]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] ADD  CONSTRAINT [uCommerce_DF_ProductCatalog_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] ADD  CONSTRAINT [uCommerce_DF_ProductCatalog_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] ADD  CONSTRAINT [uCommerce_DF_ProductCatalog_ModifiedOn]  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] ADD  CONSTRAINT [uCommerce_DF_ProductCatalog_CreatedBy]  DEFAULT (N'(Unknown)') FOR [CreatedBy]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] ADD  CONSTRAINT [uCommerce_DF_ProductCatalog_ModifiedBy]  DEFAULT (N'(Unknown)') FOR [ModifiedBy]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroup] ADD  CONSTRAINT [uCommerce_DF_ProductCatalogGroup_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroup] ADD  CONSTRAINT [uCommerce_DF_ProductCatalogGroup_CreateCustomersAsMembers]  DEFAULT ((0)) FOR [CreateCustomersAsUmbracoMembers]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroup] ADD  CONSTRAINT [DF_uCommerce_ProductCatalogGroup_ProductReviewsRequireApproval]  DEFAULT ((0)) FOR [ProductReviewsRequireApproval]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinition] ADD  CONSTRAINT [uCommerce_DF_ProductDefinition_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinition] ADD  CONSTRAINT [DF_uCommerce_ProductDefinition_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionField] ADD  CONSTRAINT [uCommerce_DF_ProductDefinitionField_DisplayOnSite]  DEFAULT ((0)) FOR [DisplayOnSite]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionField] ADD  CONSTRAINT [uCommerce_DF_ProductDefinitionField_IsVariantProperty]  DEFAULT ((0)) FOR [IsVariantProperty]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionField] ADD  CONSTRAINT [uCommerce_DF_ProductDefinitionField_Searchable]  DEFAULT ((0)) FOR [Searchable]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionField] ADD  CONSTRAINT [uCommerce_DF_ProductDefinitionField_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionField] ADD  CONSTRAINT [DF_uCommerce_ProductDefinitionField_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[uCommerce_ProductRelationType] ADD  CONSTRAINT [DF_uCommerce_ProductRelation_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[uCommerce_ProductRelationType] ADD  CONSTRAINT [DF_uCommerce_ProductRelation_ModifiedOn]  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[uCommerce_ProductReviewComment] ADD  CONSTRAINT [DF_uCommerce_ProductReviewComment_Helpful]  DEFAULT ((0)) FOR [Helpful]
GO
ALTER TABLE [dbo].[uCommerce_ProductReviewComment] ADD  CONSTRAINT [DF_uCommerce_ProductReviewComment_Unhelpful]  DEFAULT ((0)) FOR [Unhelpful]
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder] ADD  CONSTRAINT [uCommerce_DF_Order_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder] ADD  CONSTRAINT [uCommerce_DF_PurchaseOrder_BasketId]  DEFAULT (newid()) FOR [BasketId]
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder] ADD  DEFAULT (newid()) FOR [OrderGuid]
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[uCommerce_QuantityTarget] ADD  CONSTRAINT [DF_uCommerce_Quantity_Target_MinAmount]  DEFAULT ((0)) FOR [MinQuantity]
GO
ALTER TABLE [dbo].[uCommerce_Shipment] ADD  CONSTRAINT [uCommerce_DF_Shipping_Created]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[uCommerce_Shipment] ADD  CONSTRAINT [uCommerce_DF_Shipping_ShippingPrice]  DEFAULT ((0)) FOR [ShipmentPrice]
GO
ALTER TABLE [dbo].[uCommerce_Shipment] ADD  DEFAULT ((0)) FOR [Tax]
GO
ALTER TABLE [dbo].[uCommerce_Shipment] ADD  DEFAULT ((0)) FOR [TaxRate]
GO
ALTER TABLE [dbo].[uCommerce_Shipment] ADD  DEFAULT ((0)) FOR [ShipmentTotal]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethod] ADD  CONSTRAINT [uCommerce_DF_ShippingMethod_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[uCommerce_VoucherCode] ADD  CONSTRAINT [DF_uCommerce_VoucherCode_NumberUsed]  DEFAULT ((0)) FOR [NumberUsed]
GO
ALTER TABLE [dbo].[umbracoLog] ADD  CONSTRAINT [DF_umbracoLog_Datestamp]  DEFAULT (getdate()) FOR [Datestamp]
GO
ALTER TABLE [dbo].[umbracoNode] ADD  CONSTRAINT [DF_umbracoNode_trashed]  DEFAULT ('0') FOR [trashed]
GO
ALTER TABLE [dbo].[umbracoNode] ADD  CONSTRAINT [DF_umbracoNode_createDate]  DEFAULT (getdate()) FOR [createDate]
GO
ALTER TABLE [dbo].[umbracoRelation] ADD  CONSTRAINT [DF_umbracoRelation_datetime]  DEFAULT (getdate()) FOR [datetime]
GO
ALTER TABLE [dbo].[umbracoUser] ADD  CONSTRAINT [DF_umbracoUser_userDisabled]  DEFAULT ('0') FOR [userDisabled]
GO
ALTER TABLE [dbo].[umbracoUser] ADD  CONSTRAINT [DF_umbracoUser_userNoConsole]  DEFAULT ('0') FOR [userNoConsole]
GO
ALTER TABLE [dbo].[umbracoUser] ADD  CONSTRAINT [DF_umbracoUser_defaultToLiveEditing]  DEFAULT ('0') FOR [defaultToLiveEditing]
GO
ALTER TABLE [dbo].[cmsContent]  WITH CHECK ADD  CONSTRAINT [FK_cmsContent_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsContent] CHECK CONSTRAINT [FK_cmsContent_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsContentType]  WITH CHECK ADD  CONSTRAINT [FK_cmsContentType_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsContentType] CHECK CONSTRAINT [FK_cmsContentType_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsContentType2ContentType]  WITH CHECK ADD  CONSTRAINT [FK_cmsContentType2ContentType_umbracoNode_child] FOREIGN KEY([childContentTypeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsContentType2ContentType] CHECK CONSTRAINT [FK_cmsContentType2ContentType_umbracoNode_child]
GO
ALTER TABLE [dbo].[cmsContentType2ContentType]  WITH CHECK ADD  CONSTRAINT [FK_cmsContentType2ContentType_umbracoNode_parent] FOREIGN KEY([parentContentTypeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsContentType2ContentType] CHECK CONSTRAINT [FK_cmsContentType2ContentType_umbracoNode_parent]
GO
ALTER TABLE [dbo].[cmsContentTypeAllowedContentType]  WITH CHECK ADD  CONSTRAINT [FK_cmsContentTypeAllowedContentType_cmsContentType] FOREIGN KEY([Id])
REFERENCES [dbo].[cmsContentType] ([nodeId])
GO
ALTER TABLE [dbo].[cmsContentTypeAllowedContentType] CHECK CONSTRAINT [FK_cmsContentTypeAllowedContentType_cmsContentType]
GO
ALTER TABLE [dbo].[cmsContentTypeAllowedContentType]  WITH CHECK ADD  CONSTRAINT [FK_cmsContentTypeAllowedContentType_cmsContentType1] FOREIGN KEY([AllowedId])
REFERENCES [dbo].[cmsContentType] ([nodeId])
GO
ALTER TABLE [dbo].[cmsContentTypeAllowedContentType] CHECK CONSTRAINT [FK_cmsContentTypeAllowedContentType_cmsContentType1]
GO
ALTER TABLE [dbo].[cmsContentVersion]  WITH CHECK ADD  CONSTRAINT [FK_cmsContentVersion_cmsContent_nodeId] FOREIGN KEY([ContentId])
REFERENCES [dbo].[cmsContent] ([nodeId])
GO
ALTER TABLE [dbo].[cmsContentVersion] CHECK CONSTRAINT [FK_cmsContentVersion_cmsContent_nodeId]
GO
ALTER TABLE [dbo].[cmsContentXml]  WITH CHECK ADD  CONSTRAINT [FK_cmsContentXml_cmsContent_nodeId] FOREIGN KEY([nodeId])
REFERENCES [dbo].[cmsContent] ([nodeId])
GO
ALTER TABLE [dbo].[cmsContentXml] CHECK CONSTRAINT [FK_cmsContentXml_cmsContent_nodeId]
GO
ALTER TABLE [dbo].[cmsDataType]  WITH CHECK ADD  CONSTRAINT [FK_cmsDataType_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsDataType] CHECK CONSTRAINT [FK_cmsDataType_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsDataTypePreValues]  WITH CHECK ADD  CONSTRAINT [FK_cmsDataTypePreValues_cmsDataType_nodeId] FOREIGN KEY([datatypeNodeId])
REFERENCES [dbo].[cmsDataType] ([nodeId])
GO
ALTER TABLE [dbo].[cmsDataTypePreValues] CHECK CONSTRAINT [FK_cmsDataTypePreValues_cmsDataType_nodeId]
GO
ALTER TABLE [dbo].[cmsDocument]  WITH CHECK ADD  CONSTRAINT [FK_cmsDocument_cmsContent_nodeId] FOREIGN KEY([nodeId])
REFERENCES [dbo].[cmsContent] ([nodeId])
GO
ALTER TABLE [dbo].[cmsDocument] CHECK CONSTRAINT [FK_cmsDocument_cmsContent_nodeId]
GO
ALTER TABLE [dbo].[cmsDocument]  WITH CHECK ADD  CONSTRAINT [FK_cmsDocument_cmsTemplate_nodeId] FOREIGN KEY([templateId])
REFERENCES [dbo].[cmsTemplate] ([nodeId])
GO
ALTER TABLE [dbo].[cmsDocument] CHECK CONSTRAINT [FK_cmsDocument_cmsTemplate_nodeId]
GO
ALTER TABLE [dbo].[cmsDocument]  WITH CHECK ADD  CONSTRAINT [FK_cmsDocument_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsDocument] CHECK CONSTRAINT [FK_cmsDocument_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsDocumentType]  WITH CHECK ADD  CONSTRAINT [FK_cmsDocumentType_cmsContentType_nodeId] FOREIGN KEY([contentTypeNodeId])
REFERENCES [dbo].[cmsContentType] ([nodeId])
GO
ALTER TABLE [dbo].[cmsDocumentType] CHECK CONSTRAINT [FK_cmsDocumentType_cmsContentType_nodeId]
GO
ALTER TABLE [dbo].[cmsDocumentType]  WITH CHECK ADD  CONSTRAINT [FK_cmsDocumentType_cmsTemplate_nodeId] FOREIGN KEY([templateNodeId])
REFERENCES [dbo].[cmsTemplate] ([nodeId])
GO
ALTER TABLE [dbo].[cmsDocumentType] CHECK CONSTRAINT [FK_cmsDocumentType_cmsTemplate_nodeId]
GO
ALTER TABLE [dbo].[cmsDocumentType]  WITH CHECK ADD  CONSTRAINT [FK_cmsDocumentType_umbracoNode_id] FOREIGN KEY([contentTypeNodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsDocumentType] CHECK CONSTRAINT [FK_cmsDocumentType_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsLanguageText]  WITH CHECK ADD  CONSTRAINT [FK_cmsLanguageText_cmsDictionary_id] FOREIGN KEY([UniqueId])
REFERENCES [dbo].[cmsDictionary] ([id])
GO
ALTER TABLE [dbo].[cmsLanguageText] CHECK CONSTRAINT [FK_cmsLanguageText_cmsDictionary_id]
GO
ALTER TABLE [dbo].[cmsMacroProperty]  WITH CHECK ADD  CONSTRAINT [FK_cmsMacroProperty_cmsMacro_id] FOREIGN KEY([macro])
REFERENCES [dbo].[cmsMacro] ([id])
GO
ALTER TABLE [dbo].[cmsMacroProperty] CHECK CONSTRAINT [FK_cmsMacroProperty_cmsMacro_id]
GO
ALTER TABLE [dbo].[cmsMacroProperty]  WITH CHECK ADD  CONSTRAINT [FK_cmsMacroProperty_cmsMacroPropertyType_id] FOREIGN KEY([macroPropertyType])
REFERENCES [dbo].[cmsMacroPropertyType] ([id])
GO
ALTER TABLE [dbo].[cmsMacroProperty] CHECK CONSTRAINT [FK_cmsMacroProperty_cmsMacroPropertyType_id]
GO
ALTER TABLE [dbo].[cmsMember]  WITH CHECK ADD  CONSTRAINT [FK_cmsMember_cmsContent_nodeId] FOREIGN KEY([nodeId])
REFERENCES [dbo].[cmsContent] ([nodeId])
GO
ALTER TABLE [dbo].[cmsMember] CHECK CONSTRAINT [FK_cmsMember_cmsContent_nodeId]
GO
ALTER TABLE [dbo].[cmsMember]  WITH CHECK ADD  CONSTRAINT [FK_cmsMember_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsMember] CHECK CONSTRAINT [FK_cmsMember_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsMember2MemberGroup]  WITH CHECK ADD  CONSTRAINT [FK_cmsMember2MemberGroup_cmsMember_nodeId] FOREIGN KEY([Member])
REFERENCES [dbo].[cmsMember] ([nodeId])
GO
ALTER TABLE [dbo].[cmsMember2MemberGroup] CHECK CONSTRAINT [FK_cmsMember2MemberGroup_cmsMember_nodeId]
GO
ALTER TABLE [dbo].[cmsMember2MemberGroup]  WITH CHECK ADD  CONSTRAINT [FK_cmsMember2MemberGroup_umbracoNode_id] FOREIGN KEY([MemberGroup])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsMember2MemberGroup] CHECK CONSTRAINT [FK_cmsMember2MemberGroup_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsMemberType]  WITH CHECK ADD  CONSTRAINT [FK_cmsMemberType_cmsContentType_nodeId] FOREIGN KEY([NodeId])
REFERENCES [dbo].[cmsContentType] ([nodeId])
GO
ALTER TABLE [dbo].[cmsMemberType] CHECK CONSTRAINT [FK_cmsMemberType_cmsContentType_nodeId]
GO
ALTER TABLE [dbo].[cmsMemberType]  WITH CHECK ADD  CONSTRAINT [FK_cmsMemberType_umbracoNode_id] FOREIGN KEY([NodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsMemberType] CHECK CONSTRAINT [FK_cmsMemberType_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsPreviewXml]  WITH CHECK ADD  CONSTRAINT [FK_cmsPreviewXml_cmsContent_nodeId] FOREIGN KEY([nodeId])
REFERENCES [dbo].[cmsContent] ([nodeId])
GO
ALTER TABLE [dbo].[cmsPreviewXml] CHECK CONSTRAINT [FK_cmsPreviewXml_cmsContent_nodeId]
GO
ALTER TABLE [dbo].[cmsPreviewXml]  WITH CHECK ADD  CONSTRAINT [FK_cmsPreviewXml_cmsContentVersion_VersionId] FOREIGN KEY([versionId])
REFERENCES [dbo].[cmsContentVersion] ([VersionId])
GO
ALTER TABLE [dbo].[cmsPreviewXml] CHECK CONSTRAINT [FK_cmsPreviewXml_cmsContentVersion_VersionId]
GO
ALTER TABLE [dbo].[cmsPropertyData]  WITH CHECK ADD  CONSTRAINT [FK_cmsPropertyData_cmsPropertyType_id] FOREIGN KEY([propertytypeid])
REFERENCES [dbo].[cmsPropertyType] ([id])
GO
ALTER TABLE [dbo].[cmsPropertyData] CHECK CONSTRAINT [FK_cmsPropertyData_cmsPropertyType_id]
GO
ALTER TABLE [dbo].[cmsPropertyData]  WITH CHECK ADD  CONSTRAINT [FK_cmsPropertyData_umbracoNode_id] FOREIGN KEY([contentNodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsPropertyData] CHECK CONSTRAINT [FK_cmsPropertyData_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsPropertyType]  WITH CHECK ADD  CONSTRAINT [FK_cmsPropertyType_cmsContentType_nodeId] FOREIGN KEY([contentTypeId])
REFERENCES [dbo].[cmsContentType] ([nodeId])
GO
ALTER TABLE [dbo].[cmsPropertyType] CHECK CONSTRAINT [FK_cmsPropertyType_cmsContentType_nodeId]
GO
ALTER TABLE [dbo].[cmsPropertyType]  WITH CHECK ADD  CONSTRAINT [FK_cmsPropertyType_cmsDataType_nodeId] FOREIGN KEY([dataTypeId])
REFERENCES [dbo].[cmsDataType] ([nodeId])
GO
ALTER TABLE [dbo].[cmsPropertyType] CHECK CONSTRAINT [FK_cmsPropertyType_cmsDataType_nodeId]
GO
ALTER TABLE [dbo].[cmsPropertyType]  WITH CHECK ADD  CONSTRAINT [FK_cmsPropertyType_cmsPropertyTypeGroup_id] FOREIGN KEY([propertyTypeGroupId])
REFERENCES [dbo].[cmsPropertyTypeGroup] ([id])
GO
ALTER TABLE [dbo].[cmsPropertyType] CHECK CONSTRAINT [FK_cmsPropertyType_cmsPropertyTypeGroup_id]
GO
ALTER TABLE [dbo].[cmsPropertyTypeGroup]  WITH CHECK ADD  CONSTRAINT [FK_cmsPropertyTypeGroup_cmsContentType_nodeId] FOREIGN KEY([contenttypeNodeId])
REFERENCES [dbo].[cmsContentType] ([nodeId])
GO
ALTER TABLE [dbo].[cmsPropertyTypeGroup] CHECK CONSTRAINT [FK_cmsPropertyTypeGroup_cmsContentType_nodeId]
GO
ALTER TABLE [dbo].[cmsPropertyTypeGroup]  WITH CHECK ADD  CONSTRAINT [FK_cmsPropertyTypeGroup_cmsPropertyTypeGroup_id] FOREIGN KEY([parentGroupId])
REFERENCES [dbo].[cmsPropertyTypeGroup] ([id])
GO
ALTER TABLE [dbo].[cmsPropertyTypeGroup] CHECK CONSTRAINT [FK_cmsPropertyTypeGroup_cmsPropertyTypeGroup_id]
GO
ALTER TABLE [dbo].[cmsStylesheet]  WITH CHECK ADD  CONSTRAINT [FK_cmsStylesheet_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsStylesheet] CHECK CONSTRAINT [FK_cmsStylesheet_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsTagRelationship]  WITH CHECK ADD  CONSTRAINT [FK_cmsTagRelationship_cmsTags_id] FOREIGN KEY([tagId])
REFERENCES [dbo].[cmsTags] ([id])
GO
ALTER TABLE [dbo].[cmsTagRelationship] CHECK CONSTRAINT [FK_cmsTagRelationship_cmsTags_id]
GO
ALTER TABLE [dbo].[cmsTagRelationship]  WITH CHECK ADD  CONSTRAINT [FK_cmsTagRelationship_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsTagRelationship] CHECK CONSTRAINT [FK_cmsTagRelationship_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsTask]  WITH CHECK ADD  CONSTRAINT [FK_cmsTask_cmsTaskType_id] FOREIGN KEY([taskTypeId])
REFERENCES [dbo].[cmsTaskType] ([id])
GO
ALTER TABLE [dbo].[cmsTask] CHECK CONSTRAINT [FK_cmsTask_cmsTaskType_id]
GO
ALTER TABLE [dbo].[cmsTask]  WITH CHECK ADD  CONSTRAINT [FK_cmsTask_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsTask] CHECK CONSTRAINT [FK_cmsTask_umbracoNode_id]
GO
ALTER TABLE [dbo].[cmsTask]  WITH CHECK ADD  CONSTRAINT [FK_cmsTask_umbracoUser] FOREIGN KEY([parentUserId])
REFERENCES [dbo].[umbracoUser] ([id])
GO
ALTER TABLE [dbo].[cmsTask] CHECK CONSTRAINT [FK_cmsTask_umbracoUser]
GO
ALTER TABLE [dbo].[cmsTask]  WITH CHECK ADD  CONSTRAINT [FK_cmsTask_umbracoUser1] FOREIGN KEY([userId])
REFERENCES [dbo].[umbracoUser] ([id])
GO
ALTER TABLE [dbo].[cmsTask] CHECK CONSTRAINT [FK_cmsTask_umbracoUser1]
GO
ALTER TABLE [dbo].[cmsTemplate]  WITH CHECK ADD  CONSTRAINT [FK_cmsTemplate_cmsTemplate] FOREIGN KEY([master])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsTemplate] CHECK CONSTRAINT [FK_cmsTemplate_cmsTemplate]
GO
ALTER TABLE [dbo].[cmsTemplate]  WITH CHECK ADD  CONSTRAINT [FK_cmsTemplate_umbracoNode] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[cmsTemplate] CHECK CONSTRAINT [FK_cmsTemplate_umbracoNode]
GO
ALTER TABLE [dbo].[uCommerce_Address]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Address_Country] FOREIGN KEY([CountryId])
REFERENCES [dbo].[uCommerce_Country] ([CountryId])
GO
ALTER TABLE [dbo].[uCommerce_Address] CHECK CONSTRAINT [uCommerce_FK_Address_Country]
GO
ALTER TABLE [dbo].[uCommerce_Address]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Address_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[uCommerce_Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[uCommerce_Address] CHECK CONSTRAINT [uCommerce_FK_Address_Customer]
GO
ALTER TABLE [dbo].[uCommerce_AdminTab]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_AdminTab_AdminPage] FOREIGN KEY([AdminPageId])
REFERENCES [dbo].[uCommerce_AdminPage] ([AdminPageId])
GO
ALTER TABLE [dbo].[uCommerce_AdminTab] CHECK CONSTRAINT [uCommerce_FK_AdminTab_AdminPage]
GO
ALTER TABLE [dbo].[uCommerce_AmountOffOrderLinesAward]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_AmountOffOrderLinesAward_uCommerce_Award] FOREIGN KEY([AmountOffOrderLinesAwardId])
REFERENCES [dbo].[uCommerce_Award] ([AwardId])
GO
ALTER TABLE [dbo].[uCommerce_AmountOffOrderLinesAward] CHECK CONSTRAINT [FK_uCommerce_AmountOffOrderLinesAward_uCommerce_Award]
GO
ALTER TABLE [dbo].[uCommerce_AmountOffOrderTotalAward]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_AmountOffOrderTotalAward_uCommerce_Award] FOREIGN KEY([AmountOffOrderTotalAwardId])
REFERENCES [dbo].[uCommerce_Award] ([AwardId])
GO
ALTER TABLE [dbo].[uCommerce_AmountOffOrderTotalAward] CHECK CONSTRAINT [FK_uCommerce_AmountOffOrderTotalAward_uCommerce_Award]
GO
ALTER TABLE [dbo].[uCommerce_AmountOffUnitAward]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_AmountOffUnitAward_uCommerce_Award] FOREIGN KEY([AmountOffUnitAwardId])
REFERENCES [dbo].[uCommerce_Award] ([AwardId])
GO
ALTER TABLE [dbo].[uCommerce_AmountOffUnitAward] CHECK CONSTRAINT [FK_uCommerce_AmountOffUnitAward_uCommerce_Award]
GO
ALTER TABLE [dbo].[uCommerce_Award]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_Award_uCommerce_CampaignItem] FOREIGN KEY([CampaignItemId])
REFERENCES [dbo].[uCommerce_CampaignItem] ([CampaignItemId])
GO
ALTER TABLE [dbo].[uCommerce_Award] CHECK CONSTRAINT [FK_uCommerce_Award_uCommerce_CampaignItem]
GO
ALTER TABLE [dbo].[uCommerce_CampaignItem]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_CampaignItem_uCommerce_Campaign] FOREIGN KEY([CampaignId])
REFERENCES [dbo].[uCommerce_Campaign] ([CampaignId])
GO
ALTER TABLE [dbo].[uCommerce_CampaignItem] CHECK CONSTRAINT [FK_uCommerce_CampaignItem_uCommerce_Campaign]
GO
ALTER TABLE [dbo].[uCommerce_CampaignItem]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_CampaignItem_uCommerce_Definition] FOREIGN KEY([DefinitionId])
REFERENCES [dbo].[uCommerce_Definition] ([DefinitionId])
GO
ALTER TABLE [dbo].[uCommerce_CampaignItem] CHECK CONSTRAINT [FK_uCommerce_CampaignItem_uCommerce_Definition]
GO
ALTER TABLE [dbo].[uCommerce_CampaignItemProperty]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_CampaignItemProperty_uCommerce_CampaignItem] FOREIGN KEY([CampaignItemId])
REFERENCES [dbo].[uCommerce_CampaignItem] ([CampaignItemId])
GO
ALTER TABLE [dbo].[uCommerce_CampaignItemProperty] CHECK CONSTRAINT [FK_uCommerce_CampaignItemProperty_uCommerce_CampaignItem]
GO
ALTER TABLE [dbo].[uCommerce_CampaignItemProperty]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_CampaignItemProperty_uCommerce_DefinitionField] FOREIGN KEY([DefinitionFieldId])
REFERENCES [dbo].[uCommerce_DefinitionField] ([DefinitionFieldId])
GO
ALTER TABLE [dbo].[uCommerce_CampaignItemProperty] CHECK CONSTRAINT [FK_uCommerce_CampaignItemProperty_uCommerce_DefinitionField]
GO
ALTER TABLE [dbo].[uCommerce_Category]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_Category_ParentCategory] FOREIGN KEY([ParentCategoryId])
REFERENCES [dbo].[uCommerce_Category] ([CategoryId])
GO
ALTER TABLE [dbo].[uCommerce_Category] CHECK CONSTRAINT [FK_uCommerce_Category_ParentCategory]
GO
ALTER TABLE [dbo].[uCommerce_Category]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_Category_uCommerce_Definition] FOREIGN KEY([DefinitionId])
REFERENCES [dbo].[uCommerce_Definition] ([DefinitionId])
GO
ALTER TABLE [dbo].[uCommerce_Category] CHECK CONSTRAINT [FK_uCommerce_Category_uCommerce_Definition]
GO
ALTER TABLE [dbo].[uCommerce_Category]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Category_ProductCatalog] FOREIGN KEY([ProductCatalogId])
REFERENCES [dbo].[uCommerce_ProductCatalog] ([ProductCatalogId])
GO
ALTER TABLE [dbo].[uCommerce_Category] CHECK CONSTRAINT [uCommerce_FK_Category_ProductCatalog]
GO
ALTER TABLE [dbo].[uCommerce_CategoryDescription]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_CategoryDescription_Category] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[uCommerce_Category] ([CategoryId])
GO
ALTER TABLE [dbo].[uCommerce_CategoryDescription] CHECK CONSTRAINT [uCommerce_FK_CategoryDescription_Category]
GO
ALTER TABLE [dbo].[uCommerce_CategoryProductRelation]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_CategoryProductRelation_Category] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[uCommerce_Category] ([CategoryId])
GO
ALTER TABLE [dbo].[uCommerce_CategoryProductRelation] CHECK CONSTRAINT [uCommerce_FK_CategoryProductRelation_Category]
GO
ALTER TABLE [dbo].[uCommerce_CategoryProductRelation]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_CategoryProductRelation_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[uCommerce_Product] ([ProductId])
GO
ALTER TABLE [dbo].[uCommerce_CategoryProductRelation] CHECK CONSTRAINT [uCommerce_FK_CategoryProductRelation_Product]
GO
ALTER TABLE [dbo].[uCommerce_CategoryProperty]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_CategoryProperty_uCommerce_Category] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[uCommerce_Category] ([CategoryId])
GO
ALTER TABLE [dbo].[uCommerce_CategoryProperty] CHECK CONSTRAINT [FK_uCommerce_CategoryProperty_uCommerce_Category]
GO
ALTER TABLE [dbo].[uCommerce_CategoryProperty]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_CategoryProperty_uCommerce_DefinitionField] FOREIGN KEY([DefinitionFieldId])
REFERENCES [dbo].[uCommerce_DefinitionField] ([DefinitionFieldId])
GO
ALTER TABLE [dbo].[uCommerce_CategoryProperty] CHECK CONSTRAINT [FK_uCommerce_CategoryProperty_uCommerce_DefinitionField]
GO
ALTER TABLE [dbo].[uCommerce_CategoryTarget]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_CategoryTarget_uCommerce_CategoryTarget] FOREIGN KEY([CategoryTargetId])
REFERENCES [dbo].[uCommerce_Target] ([TargetId])
GO
ALTER TABLE [dbo].[uCommerce_CategoryTarget] CHECK CONSTRAINT [FK_uCommerce_CategoryTarget_uCommerce_CategoryTarget]
GO
ALTER TABLE [dbo].[uCommerce_DataTypeEnum]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_DataTypeEnum_DataType] FOREIGN KEY([DataTypeId])
REFERENCES [dbo].[uCommerce_DataType] ([DataTypeId])
GO
ALTER TABLE [dbo].[uCommerce_DataTypeEnum] CHECK CONSTRAINT [uCommerce_FK_DataTypeEnum_DataType]
GO
ALTER TABLE [dbo].[uCommerce_DataTypeEnumDescription]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_DataTypeEnumDescription_DataTypeEnum] FOREIGN KEY([DataTypeEnumId])
REFERENCES [dbo].[uCommerce_DataTypeEnum] ([DataTypeEnumId])
GO
ALTER TABLE [dbo].[uCommerce_DataTypeEnumDescription] CHECK CONSTRAINT [uCommerce_FK_DataTypeEnumDescription_DataTypeEnum]
GO
ALTER TABLE [dbo].[uCommerce_Definition]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_Definition_uCommerce_DefinitionType] FOREIGN KEY([DefinitionTypeId])
REFERENCES [dbo].[uCommerce_DefinitionType] ([DefinitionTypeId])
GO
ALTER TABLE [dbo].[uCommerce_Definition] CHECK CONSTRAINT [FK_uCommerce_Definition_uCommerce_DefinitionType]
GO
ALTER TABLE [dbo].[uCommerce_DefinitionField]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_DefinitionField_uCommerce_DataType] FOREIGN KEY([DataTypeId])
REFERENCES [dbo].[uCommerce_DataType] ([DataTypeId])
GO
ALTER TABLE [dbo].[uCommerce_DefinitionField] CHECK CONSTRAINT [FK_uCommerce_DefinitionField_uCommerce_DataType]
GO
ALTER TABLE [dbo].[uCommerce_DefinitionField]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_DefinitionField_uCommerce_Definition] FOREIGN KEY([DefinitionId])
REFERENCES [dbo].[uCommerce_Definition] ([DefinitionId])
GO
ALTER TABLE [dbo].[uCommerce_DefinitionField] CHECK CONSTRAINT [FK_uCommerce_DefinitionField_uCommerce_Definition]
GO
ALTER TABLE [dbo].[uCommerce_DefinitionFieldDescription]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_DefinitionFieldDescription_uCommerce_DefinitionField] FOREIGN KEY([DefinitionFieldId])
REFERENCES [dbo].[uCommerce_DefinitionField] ([DefinitionFieldId])
GO
ALTER TABLE [dbo].[uCommerce_DefinitionFieldDescription] CHECK CONSTRAINT [FK_uCommerce_DefinitionFieldDescription_uCommerce_DefinitionField]
GO
ALTER TABLE [dbo].[uCommerce_DefinitionTypeDescription]  WITH CHECK ADD  CONSTRAINT [FK_DefinitionTypeDescription_uCommerce_DefinitionType] FOREIGN KEY([DefinitionTypeId])
REFERENCES [dbo].[uCommerce_DefinitionType] ([DefinitionTypeId])
GO
ALTER TABLE [dbo].[uCommerce_DefinitionTypeDescription] CHECK CONSTRAINT [FK_DefinitionTypeDescription_uCommerce_DefinitionType]
GO
ALTER TABLE [dbo].[uCommerce_Discount]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_Discount_uCommerce_PurchaseOrder] FOREIGN KEY([OrderId])
REFERENCES [dbo].[uCommerce_PurchaseOrder] ([OrderId])
GO
ALTER TABLE [dbo].[uCommerce_Discount] CHECK CONSTRAINT [FK_uCommerce_Discount_uCommerce_PurchaseOrder]
GO
ALTER TABLE [dbo].[uCommerce_EmailContent]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_EmailContent_EmailProfile] FOREIGN KEY([EmailProfileId])
REFERENCES [dbo].[uCommerce_EmailProfile] ([EmailProfileId])
GO
ALTER TABLE [dbo].[uCommerce_EmailContent] CHECK CONSTRAINT [uCommerce_FK_EmailContent_EmailProfile]
GO
ALTER TABLE [dbo].[uCommerce_EmailContent]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_EmailContent_EmailType] FOREIGN KEY([EmailTypeId])
REFERENCES [dbo].[uCommerce_EmailType] ([EmailTypeId])
GO
ALTER TABLE [dbo].[uCommerce_EmailContent] CHECK CONSTRAINT [uCommerce_FK_EmailContent_EmailType]
GO
ALTER TABLE [dbo].[uCommerce_EmailProfileInformation]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_EmailProfileInformation_uCommerce_EmailProfile] FOREIGN KEY([EmailProfileId])
REFERENCES [dbo].[uCommerce_EmailProfile] ([EmailProfileId])
GO
ALTER TABLE [dbo].[uCommerce_EmailProfileInformation] CHECK CONSTRAINT [FK_uCommerce_EmailProfileInformation_uCommerce_EmailProfile]
GO
ALTER TABLE [dbo].[uCommerce_EmailProfileInformation]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_EmailProfileInformation_uCommerce_EmailType] FOREIGN KEY([EmailTypeId])
REFERENCES [dbo].[uCommerce_EmailType] ([EmailTypeId])
GO
ALTER TABLE [dbo].[uCommerce_EmailProfileInformation] CHECK CONSTRAINT [FK_uCommerce_EmailProfileInformation_uCommerce_EmailType]
GO
ALTER TABLE [dbo].[uCommerce_EmailTypeParameter]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_EmailTypeParameter_EmailParameter] FOREIGN KEY([EmailParameterId])
REFERENCES [dbo].[uCommerce_EmailParameter] ([EmailParameterId])
GO
ALTER TABLE [dbo].[uCommerce_EmailTypeParameter] CHECK CONSTRAINT [uCommerce_FK_EmailTypeParameter_EmailParameter]
GO
ALTER TABLE [dbo].[uCommerce_EmailTypeParameter]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_EmailTypeParameter_EmailType] FOREIGN KEY([EmailTypeId])
REFERENCES [dbo].[uCommerce_EmailType] ([EmailTypeId])
GO
ALTER TABLE [dbo].[uCommerce_EmailTypeParameter] CHECK CONSTRAINT [uCommerce_FK_EmailTypeParameter_EmailType]
GO
ALTER TABLE [dbo].[uCommerce_EntityUiDescription]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_EntityUiDescription_uCommerce_EntityUi] FOREIGN KEY([EntityUiId])
REFERENCES [dbo].[uCommerce_EntityUi] ([EntityUiId])
GO
ALTER TABLE [dbo].[uCommerce_EntityUiDescription] CHECK CONSTRAINT [FK_uCommerce_EntityUiDescription_uCommerce_EntityUi]
GO
ALTER TABLE [dbo].[uCommerce_OrderAddress]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_OrderAddress_uCommerce_PurchaseOrder] FOREIGN KEY([OrderId])
REFERENCES [dbo].[uCommerce_PurchaseOrder] ([OrderId])
GO
ALTER TABLE [dbo].[uCommerce_OrderAddress] CHECK CONSTRAINT [FK_uCommerce_OrderAddress_uCommerce_PurchaseOrder]
GO
ALTER TABLE [dbo].[uCommerce_OrderAddress]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_OrderAddress_Country] FOREIGN KEY([CountryId])
REFERENCES [dbo].[uCommerce_Country] ([CountryId])
GO
ALTER TABLE [dbo].[uCommerce_OrderAddress] CHECK CONSTRAINT [uCommerce_FK_OrderAddress_Country]
GO
ALTER TABLE [dbo].[uCommerce_OrderLine]  WITH CHECK ADD  CONSTRAINT [FK_OrderLine_Shipment] FOREIGN KEY([ShipmentId])
REFERENCES [dbo].[uCommerce_Shipment] ([ShipmentId])
GO
ALTER TABLE [dbo].[uCommerce_OrderLine] CHECK CONSTRAINT [FK_OrderLine_Shipment]
GO
ALTER TABLE [dbo].[uCommerce_OrderLine]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_OrderLine_Order] FOREIGN KEY([OrderId])
REFERENCES [dbo].[uCommerce_PurchaseOrder] ([OrderId])
GO
ALTER TABLE [dbo].[uCommerce_OrderLine] CHECK CONSTRAINT [uCommerce_FK_OrderLine_Order]
GO
ALTER TABLE [dbo].[uCommerce_OrderLineDiscountRelation]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_OrderLineDiscountRelation_uCommerce_Discount] FOREIGN KEY([DiscountId])
REFERENCES [dbo].[uCommerce_Discount] ([DiscountId])
GO
ALTER TABLE [dbo].[uCommerce_OrderLineDiscountRelation] CHECK CONSTRAINT [FK_uCommerce_OrderLineDiscountRelation_uCommerce_Discount]
GO
ALTER TABLE [dbo].[uCommerce_OrderLineDiscountRelation]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_OrderLineDiscountRelation_uCommerce_OrderLine] FOREIGN KEY([OrderLineId])
REFERENCES [dbo].[uCommerce_OrderLine] ([OrderLineId])
GO
ALTER TABLE [dbo].[uCommerce_OrderLineDiscountRelation] CHECK CONSTRAINT [FK_uCommerce_OrderLineDiscountRelation_uCommerce_OrderLine]
GO
ALTER TABLE [dbo].[uCommerce_OrderProperty]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_OrderProperty_uCommerce_OrderLine] FOREIGN KEY([OrderLineId])
REFERENCES [dbo].[uCommerce_OrderLine] ([OrderLineId])
GO
ALTER TABLE [dbo].[uCommerce_OrderProperty] CHECK CONSTRAINT [FK_uCommerce_OrderProperty_uCommerce_OrderLine]
GO
ALTER TABLE [dbo].[uCommerce_OrderProperty]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_OrderProperty_uCommerce_PurchaseOrder] FOREIGN KEY([OrderId])
REFERENCES [dbo].[uCommerce_PurchaseOrder] ([OrderId])
GO
ALTER TABLE [dbo].[uCommerce_OrderProperty] CHECK CONSTRAINT [FK_uCommerce_OrderProperty_uCommerce_PurchaseOrder]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatus]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_OrderStatus_OrderStatus1] FOREIGN KEY([NextOrderStatusId])
REFERENCES [dbo].[uCommerce_OrderStatus] ([OrderStatusId])
GO
ALTER TABLE [dbo].[uCommerce_OrderStatus] CHECK CONSTRAINT [uCommerce_FK_OrderStatus_OrderStatus1]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatusAudit]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_OrderStatusAudit_OrderStatus] FOREIGN KEY([NewOrderStatusId])
REFERENCES [dbo].[uCommerce_OrderStatus] ([OrderStatusId])
GO
ALTER TABLE [dbo].[uCommerce_OrderStatusAudit] CHECK CONSTRAINT [uCommerce_FK_OrderStatusAudit_OrderStatus]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatusAudit]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_OrderStatusAudit_PurchaseOrder] FOREIGN KEY([OrderId])
REFERENCES [dbo].[uCommerce_PurchaseOrder] ([OrderId])
GO
ALTER TABLE [dbo].[uCommerce_OrderStatusAudit] CHECK CONSTRAINT [uCommerce_FK_OrderStatusAudit_PurchaseOrder]
GO
ALTER TABLE [dbo].[uCommerce_OrderStatusDescription]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_OrderStatusDescription_OrderStatus] FOREIGN KEY([OrderStatusId])
REFERENCES [dbo].[uCommerce_OrderStatus] ([OrderStatusId])
GO
ALTER TABLE [dbo].[uCommerce_OrderStatusDescription] CHECK CONSTRAINT [uCommerce_FK_OrderStatusDescription_OrderStatus]
GO
ALTER TABLE [dbo].[uCommerce_Payment]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Payment_Order] FOREIGN KEY([OrderId])
REFERENCES [dbo].[uCommerce_PurchaseOrder] ([OrderId])
GO
ALTER TABLE [dbo].[uCommerce_Payment] CHECK CONSTRAINT [uCommerce_FK_Payment_Order]
GO
ALTER TABLE [dbo].[uCommerce_Payment]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Payment_PaymentMethod] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[uCommerce_PaymentMethod] ([PaymentMethodId])
GO
ALTER TABLE [dbo].[uCommerce_Payment] CHECK CONSTRAINT [uCommerce_FK_Payment_PaymentMethod]
GO
ALTER TABLE [dbo].[uCommerce_Payment]  WITH NOCHECK ADD  CONSTRAINT [uCommerce_FK_Payment_PaymentStatus] FOREIGN KEY([PaymentStatusId])
REFERENCES [dbo].[uCommerce_PaymentStatus] ([PaymentStatusId])
GO
ALTER TABLE [dbo].[uCommerce_Payment] CHECK CONSTRAINT [uCommerce_FK_Payment_PaymentStatus]
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodCountry]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_PaymentMethodCountry_Country] FOREIGN KEY([CountryId])
REFERENCES [dbo].[uCommerce_Country] ([CountryId])
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodCountry] CHECK CONSTRAINT [uCommerce_FK_PaymentMethodCountry_Country]
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodCountry]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_PaymentMethodCountry_PaymentMethod] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[uCommerce_PaymentMethod] ([PaymentMethodId])
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodCountry] CHECK CONSTRAINT [uCommerce_FK_PaymentMethodCountry_PaymentMethod]
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodDescription]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_PaymentMethodDescription_PaymentMethod] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[uCommerce_PaymentMethod] ([PaymentMethodId])
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodDescription] CHECK CONSTRAINT [uCommerce_FK_PaymentMethodDescription_PaymentMethod]
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodFee]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_PaymentMethodFee_Currency] FOREIGN KEY([CurrencyId])
REFERENCES [dbo].[uCommerce_Currency] ([CurrencyId])
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodFee] CHECK CONSTRAINT [uCommerce_FK_PaymentMethodFee_Currency]
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodFee]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_PaymentMethodFee_PaymentMethod] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[uCommerce_PaymentMethod] ([PaymentMethodId])
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodFee] CHECK CONSTRAINT [uCommerce_FK_PaymentMethodFee_PaymentMethod]
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodFee]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_PaymentMethodFee_PriceGroup] FOREIGN KEY([PriceGroupId])
REFERENCES [dbo].[uCommerce_PriceGroup] ([PriceGroupId])
GO
ALTER TABLE [dbo].[uCommerce_PaymentMethodFee] CHECK CONSTRAINT [uCommerce_FK_PaymentMethodFee_PriceGroup]
GO
ALTER TABLE [dbo].[uCommerce_PaymentProperty]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_PaymentProperty_uCommerce_Payment] FOREIGN KEY([PaymentId])
REFERENCES [dbo].[uCommerce_Payment] ([PaymentId])
GO
ALTER TABLE [dbo].[uCommerce_PaymentProperty] CHECK CONSTRAINT [FK_uCommerce_PaymentProperty_uCommerce_Payment]
GO
ALTER TABLE [dbo].[uCommerce_Permission]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[uCommerce_Role] ([RoleId])
GO
ALTER TABLE [dbo].[uCommerce_Permission]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[uCommerce_User] ([UserId])
GO
ALTER TABLE [dbo].[uCommerce_PriceGroup]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_PriceGroup_Currency] FOREIGN KEY([CurrencyId])
REFERENCES [dbo].[uCommerce_Currency] ([CurrencyId])
GO
ALTER TABLE [dbo].[uCommerce_PriceGroup] CHECK CONSTRAINT [uCommerce_FK_PriceGroup_Currency]
GO
ALTER TABLE [dbo].[uCommerce_PriceGroupPrice]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_PriceGroupPrice_PriceGroup] FOREIGN KEY([PriceGroupId])
REFERENCES [dbo].[uCommerce_PriceGroup] ([PriceGroupId])
GO
ALTER TABLE [dbo].[uCommerce_PriceGroupPrice] CHECK CONSTRAINT [uCommerce_FK_PriceGroupPrice_PriceGroup]
GO
ALTER TABLE [dbo].[uCommerce_PriceGroupPrice]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_PriceGroupPrice_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[uCommerce_Product] ([ProductId])
GO
ALTER TABLE [dbo].[uCommerce_PriceGroupPrice] CHECK CONSTRAINT [uCommerce_FK_PriceGroupPrice_Product]
GO
ALTER TABLE [dbo].[uCommerce_Product]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_Product_ParentProduct] FOREIGN KEY([ParentProductId])
REFERENCES [dbo].[uCommerce_Product] ([ProductId])
GO
ALTER TABLE [dbo].[uCommerce_Product] CHECK CONSTRAINT [FK_uCommerce_Product_ParentProduct]
GO
ALTER TABLE [dbo].[uCommerce_Product]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Product_ProductDefinition] FOREIGN KEY([ProductDefinitionId])
REFERENCES [dbo].[uCommerce_ProductDefinition] ([ProductDefinitionId])
GO
ALTER TABLE [dbo].[uCommerce_Product] CHECK CONSTRAINT [uCommerce_FK_Product_ProductDefinition]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Catalog_CatalogGroup] FOREIGN KEY([ProductCatalogGroupId])
REFERENCES [dbo].[uCommerce_ProductCatalogGroup] ([ProductCatalogGroupId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] CHECK CONSTRAINT [uCommerce_FK_Catalog_CatalogGroup]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Catalog_PriceGroup] FOREIGN KEY([PriceGroupId])
REFERENCES [dbo].[uCommerce_PriceGroup] ([PriceGroupId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalog] CHECK CONSTRAINT [uCommerce_FK_Catalog_PriceGroup]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogDescription]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductCatalogDescription_ProductCatalog] FOREIGN KEY([ProductCatalogId])
REFERENCES [dbo].[uCommerce_ProductCatalog] ([ProductCatalogId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogDescription] CHECK CONSTRAINT [uCommerce_FK_ProductCatalogDescription_ProductCatalog]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroup]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductCatalogGroup_Currency] FOREIGN KEY([CurrencyId])
REFERENCES [dbo].[uCommerce_Currency] ([CurrencyId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroup] CHECK CONSTRAINT [uCommerce_FK_ProductCatalogGroup_Currency]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroup]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductCatalogGroup_EmailProfile] FOREIGN KEY([EmailProfileId])
REFERENCES [dbo].[uCommerce_EmailProfile] ([EmailProfileId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroup] CHECK CONSTRAINT [uCommerce_FK_ProductCatalogGroup_EmailProfile]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroup]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductCatalogGroup_OrderNumbers] FOREIGN KEY([OrderNumberId])
REFERENCES [dbo].[uCommerce_OrderNumberSerie] ([OrderNumberId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroup] CHECK CONSTRAINT [uCommerce_FK_ProductCatalogGroup_OrderNumbers]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupCampaignRelation]  WITH CHECK ADD FOREIGN KEY([CampaignId])
REFERENCES [dbo].[uCommerce_Campaign] ([CampaignId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupCampaignRelation]  WITH CHECK ADD FOREIGN KEY([ProductCatalogGroupId])
REFERENCES [dbo].[uCommerce_ProductCatalogGroup] ([ProductCatalogGroupId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupPaymentMethodMap]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductCatalogGroupPaymentMethodMap_PaymentMethod] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[uCommerce_PaymentMethod] ([PaymentMethodId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupPaymentMethodMap] CHECK CONSTRAINT [uCommerce_FK_ProductCatalogGroupPaymentMethodMap_PaymentMethod]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupPaymentMethodMap]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductCatalogGroupPaymentMethodMap_ProductCatalogGroup] FOREIGN KEY([ProductCatalogGroupId])
REFERENCES [dbo].[uCommerce_ProductCatalogGroup] ([ProductCatalogGroupId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupPaymentMethodMap] CHECK CONSTRAINT [uCommerce_FK_ProductCatalogGroupPaymentMethodMap_ProductCatalogGroup]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupShippingMethodMap]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductCatalogGroupShippingMethodMap_ProductCatalogGroup] FOREIGN KEY([ProductCatalogGroupId])
REFERENCES [dbo].[uCommerce_ProductCatalogGroup] ([ProductCatalogGroupId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupShippingMethodMap] CHECK CONSTRAINT [uCommerce_FK_ProductCatalogGroupShippingMethodMap_ProductCatalogGroup]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupShippingMethodMap]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductCatalogGroupShippingMethodMap_ShippingMethod] FOREIGN KEY([ShippingMethodId])
REFERENCES [dbo].[uCommerce_ShippingMethod] ([ShippingMethodId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogGroupShippingMethodMap] CHECK CONSTRAINT [uCommerce_FK_ProductCatalogGroupShippingMethodMap_ShippingMethod]
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogTarget]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductCatalogTarget_uCommerce_Target] FOREIGN KEY([ProductCatalogTargetId])
REFERENCES [dbo].[uCommerce_Target] ([TargetId])
GO
ALTER TABLE [dbo].[uCommerce_ProductCatalogTarget] CHECK CONSTRAINT [FK_uCommerce_ProductCatalogTarget_uCommerce_Target]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinition]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductDefinition_ProductDefinition] FOREIGN KEY([ProductDefinitionId])
REFERENCES [dbo].[uCommerce_ProductDefinition] ([ProductDefinitionId])
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinition] CHECK CONSTRAINT [uCommerce_FK_ProductDefinition_ProductDefinition]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionField]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductDefinitionField_DataType] FOREIGN KEY([DataTypeId])
REFERENCES [dbo].[uCommerce_DataType] ([DataTypeId])
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionField] CHECK CONSTRAINT [uCommerce_FK_ProductDefinitionField_DataType]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionField]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductDefinitionField_ProductDefinition] FOREIGN KEY([ProductDefinitionId])
REFERENCES [dbo].[uCommerce_ProductDefinition] ([ProductDefinitionId])
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionField] CHECK CONSTRAINT [uCommerce_FK_ProductDefinitionField_ProductDefinition]
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionFieldDescription]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductDefinitionFieldDescription_ProductDefinitionField] FOREIGN KEY([ProductDefinitionFieldId])
REFERENCES [dbo].[uCommerce_ProductDefinitionField] ([ProductDefinitionFieldId])
GO
ALTER TABLE [dbo].[uCommerce_ProductDefinitionFieldDescription] CHECK CONSTRAINT [uCommerce_FK_ProductDefinitionFieldDescription_ProductDefinitionField]
GO
ALTER TABLE [dbo].[uCommerce_ProductDescription]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductDescription_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[uCommerce_Product] ([ProductId])
GO
ALTER TABLE [dbo].[uCommerce_ProductDescription] CHECK CONSTRAINT [uCommerce_FK_ProductDescription_Product]
GO
ALTER TABLE [dbo].[uCommerce_ProductDescriptionProperty]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductDescriptionProperty_ProductDefinitionField] FOREIGN KEY([ProductDefinitionFieldId])
REFERENCES [dbo].[uCommerce_ProductDefinitionField] ([ProductDefinitionFieldId])
GO
ALTER TABLE [dbo].[uCommerce_ProductDescriptionProperty] CHECK CONSTRAINT [uCommerce_FK_ProductDescriptionProperty_ProductDefinitionField]
GO
ALTER TABLE [dbo].[uCommerce_ProductDescriptionProperty]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductDescriptionProperty_ProductDescription] FOREIGN KEY([ProductDescriptionId])
REFERENCES [dbo].[uCommerce_ProductDescription] ([ProductDescriptionId])
GO
ALTER TABLE [dbo].[uCommerce_ProductDescriptionProperty] CHECK CONSTRAINT [uCommerce_FK_ProductDescriptionProperty_ProductDescription]
GO
ALTER TABLE [dbo].[uCommerce_ProductProperty]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductProperty_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[uCommerce_Product] ([ProductId])
GO
ALTER TABLE [dbo].[uCommerce_ProductProperty] CHECK CONSTRAINT [uCommerce_FK_ProductProperty_Product]
GO
ALTER TABLE [dbo].[uCommerce_ProductProperty]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ProductProperty_ProductDefinitionField] FOREIGN KEY([ProductDefinitionFieldId])
REFERENCES [dbo].[uCommerce_ProductDefinitionField] ([ProductDefinitionFieldId])
GO
ALTER TABLE [dbo].[uCommerce_ProductProperty] CHECK CONSTRAINT [uCommerce_FK_ProductProperty_ProductDefinitionField]
GO
ALTER TABLE [dbo].[uCommerce_ProductRelation]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductRelation_uCommerce_Product2] FOREIGN KEY([ProductId])
REFERENCES [dbo].[uCommerce_Product] ([ProductId])
GO
ALTER TABLE [dbo].[uCommerce_ProductRelation] CHECK CONSTRAINT [FK_uCommerce_ProductRelation_uCommerce_Product2]
GO
ALTER TABLE [dbo].[uCommerce_ProductRelation]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductRelation_uCommerce_Product3] FOREIGN KEY([RelatedProductId])
REFERENCES [dbo].[uCommerce_Product] ([ProductId])
GO
ALTER TABLE [dbo].[uCommerce_ProductRelation] CHECK CONSTRAINT [FK_uCommerce_ProductRelation_uCommerce_Product3]
GO
ALTER TABLE [dbo].[uCommerce_ProductRelation]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductRelation_uCommerce_ProductRelationType] FOREIGN KEY([ProductRelationTypeId])
REFERENCES [dbo].[uCommerce_ProductRelationType] ([ProductRelationTypeId])
GO
ALTER TABLE [dbo].[uCommerce_ProductRelation] CHECK CONSTRAINT [FK_uCommerce_ProductRelation_uCommerce_ProductRelationType]
GO
ALTER TABLE [dbo].[uCommerce_ProductReview]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductReview_uCommerce_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[uCommerce_Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[uCommerce_ProductReview] CHECK CONSTRAINT [FK_uCommerce_ProductReview_uCommerce_Customer]
GO
ALTER TABLE [dbo].[uCommerce_ProductReview]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductReview_uCommerce_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[uCommerce_Product] ([ProductId])
GO
ALTER TABLE [dbo].[uCommerce_ProductReview] CHECK CONSTRAINT [FK_uCommerce_ProductReview_uCommerce_Product]
GO
ALTER TABLE [dbo].[uCommerce_ProductReview]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductReview_uCommerce_ProductCatalogGroup] FOREIGN KEY([ProductCatalogGroupId])
REFERENCES [dbo].[uCommerce_ProductCatalogGroup] ([ProductCatalogGroupId])
GO
ALTER TABLE [dbo].[uCommerce_ProductReview] CHECK CONSTRAINT [FK_uCommerce_ProductReview_uCommerce_ProductCatalogGroup]
GO
ALTER TABLE [dbo].[uCommerce_ProductReview]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductReview_uCommerce_ProductReviewStatus] FOREIGN KEY([ProductReviewStatusId])
REFERENCES [dbo].[uCommerce_ProductReviewStatus] ([ProductReviewStatusId])
GO
ALTER TABLE [dbo].[uCommerce_ProductReview] CHECK CONSTRAINT [FK_uCommerce_ProductReview_uCommerce_ProductReviewStatus]
GO
ALTER TABLE [dbo].[uCommerce_ProductReviewComment]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductReviewComment_uCommerce_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[uCommerce_Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[uCommerce_ProductReviewComment] CHECK CONSTRAINT [FK_uCommerce_ProductReviewComment_uCommerce_Customer]
GO
ALTER TABLE [dbo].[uCommerce_ProductReviewComment]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductReviewComment_uCommerce_ProductReview] FOREIGN KEY([ProductReviewId])
REFERENCES [dbo].[uCommerce_ProductReview] ([ProductReviewId])
GO
ALTER TABLE [dbo].[uCommerce_ProductReviewComment] CHECK CONSTRAINT [FK_uCommerce_ProductReviewComment_uCommerce_ProductReview]
GO
ALTER TABLE [dbo].[uCommerce_ProductReviewComment]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductReviewComment_uCommerce_ProductReviewStatus] FOREIGN KEY([ProductReviewStatusId])
REFERENCES [dbo].[uCommerce_ProductReviewStatus] ([ProductReviewStatusId])
GO
ALTER TABLE [dbo].[uCommerce_ProductReviewComment] CHECK CONSTRAINT [FK_uCommerce_ProductReviewComment_uCommerce_ProductReviewStatus]
GO
ALTER TABLE [dbo].[uCommerce_ProductTarget]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ProductTarget_uCommerce_Target] FOREIGN KEY([ProductTargetId])
REFERENCES [dbo].[uCommerce_Target] ([TargetId])
GO
ALTER TABLE [dbo].[uCommerce_ProductTarget] CHECK CONSTRAINT [FK_uCommerce_ProductTarget_uCommerce_Target]
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_PurchaseOrder_uCommerce_OrderAddress] FOREIGN KEY([BillingAddressId])
REFERENCES [dbo].[uCommerce_OrderAddress] ([OrderAddressId])
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder] CHECK CONSTRAINT [FK_uCommerce_PurchaseOrder_uCommerce_OrderAddress]
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Order_Currency] FOREIGN KEY([CurrencyId])
REFERENCES [dbo].[uCommerce_Currency] ([CurrencyId])
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder] CHECK CONSTRAINT [uCommerce_FK_Order_Currency]
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Order_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[uCommerce_Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder] CHECK CONSTRAINT [uCommerce_FK_Order_Customer]
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Order_OrderStatus1] FOREIGN KEY([OrderStatusId])
REFERENCES [dbo].[uCommerce_OrderStatus] ([OrderStatusId])
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder] CHECK CONSTRAINT [uCommerce_FK_Order_OrderStatus1]
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Order_ProductCatalogGroup] FOREIGN KEY([ProductCatalogGroupId])
REFERENCES [dbo].[uCommerce_ProductCatalogGroup] ([ProductCatalogGroupId])
GO
ALTER TABLE [dbo].[uCommerce_PurchaseOrder] CHECK CONSTRAINT [uCommerce_FK_Order_ProductCatalogGroup]
GO
ALTER TABLE [dbo].[uCommerce_Role]  WITH CHECK ADD FOREIGN KEY([ParentRoleId])
REFERENCES [dbo].[uCommerce_Role] ([RoleId])
GO
ALTER TABLE [dbo].[uCommerce_Role]  WITH CHECK ADD FOREIGN KEY([PriceGroupId])
REFERENCES [dbo].[uCommerce_PriceGroup] ([PriceGroupId])
GO
ALTER TABLE [dbo].[uCommerce_Role]  WITH CHECK ADD FOREIGN KEY([ProductCatalogGroupId])
REFERENCES [dbo].[uCommerce_ProductCatalogGroup] ([ProductCatalogGroupId])
GO
ALTER TABLE [dbo].[uCommerce_Role]  WITH CHECK ADD FOREIGN KEY([ProductCatalogId])
REFERENCES [dbo].[uCommerce_ProductCatalog] ([ProductCatalogId])
GO
ALTER TABLE [dbo].[uCommerce_Shipment]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_Shipment_uCommerce_OrderAddress] FOREIGN KEY([ShipmentAddressId])
REFERENCES [dbo].[uCommerce_OrderAddress] ([OrderAddressId])
GO
ALTER TABLE [dbo].[uCommerce_Shipment] CHECK CONSTRAINT [FK_uCommerce_Shipment_uCommerce_OrderAddress]
GO
ALTER TABLE [dbo].[uCommerce_Shipment]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_Shipment_uCommerce_ShippingMethod] FOREIGN KEY([ShippingMethodId])
REFERENCES [dbo].[uCommerce_ShippingMethod] ([ShippingMethodId])
GO
ALTER TABLE [dbo].[uCommerce_Shipment] CHECK CONSTRAINT [FK_uCommerce_Shipment_uCommerce_ShippingMethod]
GO
ALTER TABLE [dbo].[uCommerce_Shipment]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_Shipment_PurchaseOrder] FOREIGN KEY([OrderId])
REFERENCES [dbo].[uCommerce_PurchaseOrder] ([OrderId])
GO
ALTER TABLE [dbo].[uCommerce_Shipment] CHECK CONSTRAINT [uCommerce_FK_Shipment_PurchaseOrder]
GO
ALTER TABLE [dbo].[uCommerce_ShipmentDiscountRelation]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ShipmentDiscountRelation_uCommerce_Discount] FOREIGN KEY([DiscountId])
REFERENCES [dbo].[uCommerce_Discount] ([DiscountId])
GO
ALTER TABLE [dbo].[uCommerce_ShipmentDiscountRelation] CHECK CONSTRAINT [FK_uCommerce_ShipmentDiscountRelation_uCommerce_Discount]
GO
ALTER TABLE [dbo].[uCommerce_ShipmentDiscountRelation]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_ShipmentDiscountRelation_uCommerce_Shipment] FOREIGN KEY([ShipmentId])
REFERENCES [dbo].[uCommerce_Shipment] ([ShipmentId])
GO
ALTER TABLE [dbo].[uCommerce_ShipmentDiscountRelation] CHECK CONSTRAINT [FK_uCommerce_ShipmentDiscountRelation_uCommerce_Shipment]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethod]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ShippingMethod_PaymentMethod] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[uCommerce_PaymentMethod] ([PaymentMethodId])
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethod] CHECK CONSTRAINT [uCommerce_FK_ShippingMethod_PaymentMethod]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodCountry]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ShippingMethodCountry_Country] FOREIGN KEY([CountryId])
REFERENCES [dbo].[uCommerce_Country] ([CountryId])
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodCountry] CHECK CONSTRAINT [uCommerce_FK_ShippingMethodCountry_Country]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodCountry]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ShippingMethodCountry_ShippingMethod] FOREIGN KEY([ShippingMethodId])
REFERENCES [dbo].[uCommerce_ShippingMethod] ([ShippingMethodId])
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodCountry] CHECK CONSTRAINT [uCommerce_FK_ShippingMethodCountry_ShippingMethod]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodDescription]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ShippingMethodDescription_ShippingMethod] FOREIGN KEY([ShippingMethodId])
REFERENCES [dbo].[uCommerce_ShippingMethod] ([ShippingMethodId])
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodDescription] CHECK CONSTRAINT [uCommerce_FK_ShippingMethodDescription_ShippingMethod]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPaymentMethods]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ShippingMethodPaymentMethods_PaymentMethod] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[uCommerce_PaymentMethod] ([PaymentMethodId])
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPaymentMethods] CHECK CONSTRAINT [uCommerce_FK_ShippingMethodPaymentMethods_PaymentMethod]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPaymentMethods]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ShippingMethodPaymentMethods_ShippingMethod] FOREIGN KEY([ShippingMethodId])
REFERENCES [dbo].[uCommerce_ShippingMethod] ([ShippingMethodId])
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPaymentMethods] CHECK CONSTRAINT [uCommerce_FK_ShippingMethodPaymentMethods_ShippingMethod]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPrice]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ShippingMethodPrice_Currency] FOREIGN KEY([CurrencyId])
REFERENCES [dbo].[uCommerce_Currency] ([CurrencyId])
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPrice] CHECK CONSTRAINT [uCommerce_FK_ShippingMethodPrice_Currency]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPrice]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ShippingMethodPrice_PriceGroup] FOREIGN KEY([PriceGroupId])
REFERENCES [dbo].[uCommerce_PriceGroup] ([PriceGroupId])
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPrice] CHECK CONSTRAINT [uCommerce_FK_ShippingMethodPrice_PriceGroup]
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPrice]  WITH CHECK ADD  CONSTRAINT [uCommerce_FK_ShippingMethodPrice_ShippingMethod] FOREIGN KEY([ShippingMethodId])
REFERENCES [dbo].[uCommerce_ShippingMethod] ([ShippingMethodId])
GO
ALTER TABLE [dbo].[uCommerce_ShippingMethodPrice] CHECK CONSTRAINT [uCommerce_FK_ShippingMethodPrice_ShippingMethod]
GO
ALTER TABLE [dbo].[uCommerce_Target]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_Target_uCommerce_Target] FOREIGN KEY([CampaignItemId])
REFERENCES [dbo].[uCommerce_CampaignItem] ([CampaignItemId])
GO
ALTER TABLE [dbo].[uCommerce_Target] CHECK CONSTRAINT [FK_uCommerce_Target_uCommerce_Target]
GO
ALTER TABLE [dbo].[uCommerce_VoucherCode]  WITH NOCHECK ADD  CONSTRAINT [FK_uCommerce_VoucherCode_uCommerce_VoucherCode] FOREIGN KEY([TargetId])
REFERENCES [dbo].[uCommerce_VoucherTarget] ([VoucherTargetId])
GO
ALTER TABLE [dbo].[uCommerce_VoucherCode] CHECK CONSTRAINT [FK_uCommerce_VoucherCode_uCommerce_VoucherCode]
GO
ALTER TABLE [dbo].[uCommerce_VoucherTarget]  WITH CHECK ADD  CONSTRAINT [FK_uCommerce_VoucherTarget_uCommerce_Target] FOREIGN KEY([VoucherTargetId])
REFERENCES [dbo].[uCommerce_Target] ([TargetId])
GO
ALTER TABLE [dbo].[uCommerce_VoucherTarget] CHECK CONSTRAINT [FK_uCommerce_VoucherTarget_uCommerce_Target]
GO
ALTER TABLE [dbo].[umbracoDomains]  WITH CHECK ADD  CONSTRAINT [FK_umbracoDomains_umbracoNode_id] FOREIGN KEY([domainRootStructureID])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[umbracoDomains] CHECK CONSTRAINT [FK_umbracoDomains_umbracoNode_id]
GO
ALTER TABLE [dbo].[umbracoNode]  WITH CHECK ADD  CONSTRAINT [FK_umbracoNode_umbracoNode_id] FOREIGN KEY([parentID])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[umbracoNode] CHECK CONSTRAINT [FK_umbracoNode_umbracoNode_id]
GO
ALTER TABLE [dbo].[umbracoRelation]  WITH CHECK ADD  CONSTRAINT [FK_umbracoRelation_umbracoNode] FOREIGN KEY([parentId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[umbracoRelation] CHECK CONSTRAINT [FK_umbracoRelation_umbracoNode]
GO
ALTER TABLE [dbo].[umbracoRelation]  WITH CHECK ADD  CONSTRAINT [FK_umbracoRelation_umbracoNode1] FOREIGN KEY([childId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[umbracoRelation] CHECK CONSTRAINT [FK_umbracoRelation_umbracoNode1]
GO
ALTER TABLE [dbo].[umbracoRelation]  WITH CHECK ADD  CONSTRAINT [FK_umbracoRelation_umbracoRelationType_id] FOREIGN KEY([relType])
REFERENCES [dbo].[umbracoRelationType] ([id])
GO
ALTER TABLE [dbo].[umbracoRelation] CHECK CONSTRAINT [FK_umbracoRelation_umbracoRelationType_id]
GO
ALTER TABLE [dbo].[umbracoUser]  WITH CHECK ADD  CONSTRAINT [FK_umbracoUser_umbracoUserType_id] FOREIGN KEY([userType])
REFERENCES [dbo].[umbracoUserType] ([id])
GO
ALTER TABLE [dbo].[umbracoUser] CHECK CONSTRAINT [FK_umbracoUser_umbracoUserType_id]
GO
ALTER TABLE [dbo].[umbracoUser2app]  WITH CHECK ADD  CONSTRAINT [FK_umbracoUser2app_umbracoUser_id] FOREIGN KEY([user])
REFERENCES [dbo].[umbracoUser] ([id])
GO
ALTER TABLE [dbo].[umbracoUser2app] CHECK CONSTRAINT [FK_umbracoUser2app_umbracoUser_id]
GO
ALTER TABLE [dbo].[umbracoUser2NodeNotify]  WITH CHECK ADD  CONSTRAINT [FK_umbracoUser2NodeNotify_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[umbracoUser2NodeNotify] CHECK CONSTRAINT [FK_umbracoUser2NodeNotify_umbracoNode_id]
GO
ALTER TABLE [dbo].[umbracoUser2NodeNotify]  WITH CHECK ADD  CONSTRAINT [FK_umbracoUser2NodeNotify_umbracoUser_id] FOREIGN KEY([userId])
REFERENCES [dbo].[umbracoUser] ([id])
GO
ALTER TABLE [dbo].[umbracoUser2NodeNotify] CHECK CONSTRAINT [FK_umbracoUser2NodeNotify_umbracoUser_id]
GO
ALTER TABLE [dbo].[umbracoUser2NodePermission]  WITH CHECK ADD  CONSTRAINT [FK_umbracoUser2NodePermission_umbracoNode_id] FOREIGN KEY([nodeId])
REFERENCES [dbo].[umbracoNode] ([id])
GO
ALTER TABLE [dbo].[umbracoUser2NodePermission] CHECK CONSTRAINT [FK_umbracoUser2NodePermission_umbracoNode_id]
GO
ALTER TABLE [dbo].[umbracoUser2NodePermission]  WITH CHECK ADD  CONSTRAINT [FK_umbracoUser2NodePermission_umbracoUser_id] FOREIGN KEY([userId])
REFERENCES [dbo].[umbracoUser] ([id])
GO
ALTER TABLE [dbo].[umbracoUser2NodePermission] CHECK CONSTRAINT [FK_umbracoUser2NodePermission_umbracoUser_id]
GO
USE [master]
GO
ALTER DATABASE [UTraining3] SET  READ_WRITE 
GO
