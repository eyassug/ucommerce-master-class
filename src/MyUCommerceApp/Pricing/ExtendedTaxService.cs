using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Pricing
{
	public class ExtendedTaxService : UCommerce.Catalog.TaxService
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public ExtendedTaxService(IRepository<PriceGroup> priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
		}

		public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			ProductProperty field = product["PriceGroup"];

			if (field == null && product.IsVariant)
				field = product.ParentProduct["PriceGroup"];

			if (field == null)
				return base.CalculateTax(product, priceGroup, unitPrice);

			var value = field.GetValue();

			if (value == null)
				return base.CalculateTax(product, priceGroup, unitPrice);

			var id = field.GetValue().ToString();

			int priceGroupId;
			if (int.TryParse(id, out priceGroupId))
			{
				PriceGroup priceGroupFromProduct = _priceGroupRepository.Select(x => x.PriceGroupId == priceGroupId).FirstOrDefault();
				if (priceGroupFromProduct != null)
					priceGroup = priceGroupFromProduct;
			}

			return base.CalculateTax(product, priceGroup, unitPrice);
		}
	}
}
