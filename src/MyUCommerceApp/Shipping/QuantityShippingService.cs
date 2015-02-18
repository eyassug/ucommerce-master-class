using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Transactions.Shipping;

namespace MyUCommerceApp.BusinessLogic.Shipping
{
	public class QuantityShippingService : IShippingMethodService
	{
		private readonly int _unitPrice;

		public QuantityShippingService(int unitPrice)
		{
			_unitPrice = unitPrice;
		}

		public Money CalculateShippingPrice(Shipment shipment)
		{
			int totalQuantity = shipment.OrderLines.Sum(x => x.Quantity);

			decimal shipmentPrice = totalQuantity*_unitPrice;

			return new Money(shipmentPrice,shipment.PurchaseOrder.BillingCurrency);
		}

		public bool ValidateForShipping(Shipment shipment)
		{
			var shipmentAddress = shipment.ShipmentAddress;

			if (shipmentAddress != null && shipmentAddress.Country != null)
			{
				return shipment.ShippingMethod.EligibleCountries.Contains(shipmentAddress.Country);
			}

			return false;
		}
	}
}
