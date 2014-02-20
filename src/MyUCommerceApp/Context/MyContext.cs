using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.Context
{
	public class MyContext : CatalogContext
	{
		private readonly IMemberService _memberService;
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public MyContext(
			IMemberService memberService,
			IDomainService domainService, 
			IRepository<ProductCatalogGroup> productCatalogGroupRepository, 
			IRepository<ProductCatalog> productCatalogRepository, 
			IRepository<PriceGroup> priceGroupRepository) 
			: base(domainService, 
					productCatalogGroupRepository, 
					productCatalogRepository, 
					priceGroupRepository)
		{
			_memberService = memberService;
			_priceGroupRepository = priceGroupRepository;
		}

		public override string CurrentCatalogName
		{
			get
			{
				if (HttpContext.Current.Request.QueryString["loggedin"] != null || _memberService.IsLoggedIn())
					return "Private";

				return base.CurrentCatalogName;
			}
			set { base.CurrentCatalogName = value; }
		}

		public override PriceGroup CurrentPriceGroup
		{
			get
			{
				var category = CurrentCategory;

				if (category == null) return base.CurrentPriceGroup;

				var priceGroupProperty = category.GetProperty("PriceGroup");

				if (priceGroupProperty == null) return base.CurrentPriceGroup;

				var value = priceGroupProperty.GetValue();

				if (string.IsNullOrWhiteSpace(value.ToString()) || value.ToString() == "0") return base.CurrentPriceGroup;

				var priceGroup =
					_priceGroupRepository.Select(x => x.PriceGroupId == Convert.ToInt32(value.ToString())).FirstOrDefault();

				if (priceGroup == null) return base.CurrentPriceGroup;

				return priceGroup;
			}

			set { base.CurrentPriceGroup = value; }
		}
	}
}
