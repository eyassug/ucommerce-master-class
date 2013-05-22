using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp
{
	public class MyPricingService : PricingService
	{
		public override Money GetProductPrice(Product product, PriceGroup priceGroup)
		{
			string priceGroupName 
				= HttpContext.Current.Request.QueryString["priceGroup"];
			
			if (priceGroupName != null)
			{
				var price = product.PriceGroupPrices
					.SingleOrDefault(x => x.PriceGroup.Name == priceGroupName);

				if (price == null) 
					return base.GetProductPrice(product, priceGroup);

				return new Money(
					price.Price.GetValueOrDefault(), 
					price.PriceGroup.Currency);
			}

			return base.GetProductPrice(product, priceGroup);
		}
	}
}
