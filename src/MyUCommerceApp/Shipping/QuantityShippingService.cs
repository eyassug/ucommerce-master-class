using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Transactions.Shipping;

namespace MyUCommerceApp.Shipping
{
	public class QuantityShippingService : IShippingMethodService
	{
		private readonly IRepository<Product> _productRepository;

		public QuantityShippingService(IRepository<Product> productRepository)
		{
			_productRepository = productRepository;
		}

		public Money CalculateShippingPrice(Shipment shipment)
		{
			decimal totalWeight = 0;

			var orderLinesForShipment = shipment.OrderLines;

			foreach (var orderLine in orderLinesForShipment)
			{
				var product = _productRepository.SingleOrDefault(x => x.Sku == orderLine.Sku && x.VariantSku == orderLine.VariantSku);
				totalWeight += product.Weight * orderLine.Quantity;
			}

			return new Money(totalWeight * 2,shipment.PurchaseOrder.BillingCurrency);
		}

		public bool ValidateForShipping(Shipment shipment)
		{
			if (shipment.ShipmentAddress == null || shipment.ShipmentAddress.Country != null) return true;

			return shipment.ShippingMethod.EligibleCountries.Contains(shipment.ShipmentAddress.Country);

		}
	}
}
