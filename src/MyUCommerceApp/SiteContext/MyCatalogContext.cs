﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.BusinessLogic.SiteContext
{
	public class MyCatalogContext : CatalogContext
	{
		private readonly IMemberService _memberService;
		private string _currentCatalogName;

		public MyCatalogContext(
			IDomainService domainService, 
			IRepository<ProductCatalogGroup> productCatalogGroupRepository, 
			IRepository<ProductCatalog> productCatalogRepository, 
			IRepository<PriceGroup> priceGroupRepository,
			IMemberService memberService) : base(domainService, productCatalogGroupRepository, productCatalogRepository, priceGroupRepository)
		{
			_memberService = memberService;
		}

		public override string CurrentCatalogName
		{
			get
			{
				if (System.Web.HttpContext.Current.Request.QueryString["loggedin"] == "1")
				{
					return "Private";
				}

				return _currentCatalogName;
			}
			set { _currentCatalogName = value; }
		}
	}
}