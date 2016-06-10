using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate.Type;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.Documents.Definitions;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Pricing
{
	public class ExtendedTaxService : TaxService
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public ExtendedTaxService(IRepository<PriceGroup> priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
		}

		public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			ProductProperty property = product["PriceGroup"];

			if (property == null && product.ParentProduct != null)
			{
				property = product.ParentProduct["PriceGroup"];
			}
			
			if (property == null)
				return base.CalculateTax(product, priceGroup, unitPrice);

			int priceGroupId;
			if (!int.TryParse(property.GetValue().ToString(), out priceGroupId))
			{
				return base.CalculateTax(product, priceGroup, unitPrice);				
			}

			var newPriceGroup = _priceGroupRepository.Select(x => x.PriceGroupId == priceGroupId).FirstOrDefault();

			if (newPriceGroup == null)
				return base.CalculateTax(product, priceGroup, unitPrice);

			return base.CalculateTax(product, newPriceGroup, unitPrice);
		}
	}
}
