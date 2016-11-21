using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Tax
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
			var priceGroupProperty = product["PriceGroup"];

			if (priceGroupProperty == null && product.ParentProduct != null)
			{
				priceGroupProperty = product.ParentProduct["PriceGroup"];
			}

			if (priceGroupProperty == null)
			{
				return base.CalculateTax(product, priceGroup, unitPrice);
			}

			if (priceGroupProperty.GetValue() == null) { 
				return base.CalculateTax(product, priceGroup, unitPrice);
			}

			int priceGroudId;
			if(int.TryParse(priceGroupProperty.GetValue().ToString(), out priceGroudId))
			{
				var overridenPriceGroup = _priceGroupRepository
					.Select(x => x.PriceGroupId == priceGroudId).FirstOrDefault();

				if (overridenPriceGroup != null)
				{
					priceGroup = overridenPriceGroup;
				}

			}

			return base.CalculateTax(product, priceGroup, unitPrice);
		}
	}
}
