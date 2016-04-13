using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate;
using NHibernate.Transform;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.BusinessLogic.Queries
{
	public class OrderViewQuery : ICannedQuery<OrderViewModel>
	{
		private readonly OrderStatus _orderStatus;

		public OrderViewQuery(OrderStatus orderStatus)
		{
			_orderStatus = orderStatus;
		}

		public IEnumerable<OrderViewModel> Execute(ISession session)
		{
			return session.CreateQuery(
			@"
				SELECT
					order.OrderTotal AS OrderTotal,
					order.OrderNumber AS OrderNumber,
					order.Customer.FirstName AS CustomerFirstName,
					order.Customer.EmailAddress AS CustomerEmail,
					order.BillingCurrency.ISOCode AS Currency
				FROM PurchaseOrder order
				WHERE order.OrderStatus = :orderStatus
			")
			.SetParameter("orderStatus", _orderStatus)
			.SetResultTransformer(new AliasToBeanResultTransformer(typeof(OrderViewModel)))
			.Future<OrderViewModel>().ToList();
		}
	}
}
