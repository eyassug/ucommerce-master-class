using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.Catalog;
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
			var field = product["PriceGroup"];

			if (field == null && product.IsVariant)
				field = product.ParentProduct["PriceGroup"];

			if (field == null)
				return base.CalculateTax(product, priceGroup, unitPrice);

			if (string.IsNullOrWhiteSpace(field.GetValue().ToString()))
				return base.CalculateTax(product, priceGroup, unitPrice);

			var priceGroupForProduct = _priceGroupRepository.Select(x => x.PriceGroupId == Convert.ToInt32(field.GetValue())).FirstOrDefault();
			if (priceGroupForProduct == null)
				return base.CalculateTax(product, priceGroup, unitPrice);

			return base.CalculateTax(priceGroupForProduct, unitPrice);
		}
	}
}
