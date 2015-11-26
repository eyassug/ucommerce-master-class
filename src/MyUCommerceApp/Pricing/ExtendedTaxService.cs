using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.Api;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Pricing
{
	public class AvalaraTaxService : TaxService
	{
		public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			if (!TransactionLibrary.HasBasket())
				return new Money(0, priceGroup.Currency);

			if (string.IsNullOrEmpty(TransactionLibrary.GetBillingInformation().State))
				return new Money(0,priceGroup.Currency);

			var dynmicPriceGroup = new PriceGroup();
			dynmicPriceGroup.VATRate = GetTaxRateFromAvalara(product, priceGroup, unitPrice);
			dynmicPriceGroup.Currency = priceGroup.Currency;

			return base.CalculateTax(product, dynmicPriceGroup, unitPrice);
		}

		private int GetTaxRateFromAvalara(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			return 10;
		}
	}


	public class ExtendedTaxService : TaxService
	{
		private readonly IRepository<PriceGroup> _priceGrouRepository;

		public ExtendedTaxService(IRepository<PriceGroup> priceGrouRepository)
		{
			_priceGrouRepository = priceGrouRepository;
		}

		public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			var priceGroupProperty = product["PriceGroup"];

			if (priceGroupProperty == null && product.IsVariant)
			{
				priceGroupProperty = product.ParentProduct["PriceGroup"];
			}

			if (priceGroupProperty == null)
				return base.CalculateTax(product, priceGroup, unitPrice);

			int id;
			if (int.TryParse(priceGroupProperty.GetValue().ToString(), out id))
			{
				var configuredPriceGroup =
					_priceGrouRepository.Select(x => x.PriceGroupId == id).FirstOrDefault();

				if (configuredPriceGroup == null)
					return base.CalculateTax(product, priceGroup, unitPrice);

				priceGroup = configuredPriceGroup;
			}

			return base.CalculateTax(product, priceGroup, unitPrice);
		}
	}
}
