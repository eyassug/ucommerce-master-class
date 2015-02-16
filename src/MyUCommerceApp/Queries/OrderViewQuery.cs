using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MyUCommerceApp.BusinessLogic.Queries.ViewModel;
using NHibernate;
using NHibernate.Transform;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.BusinessLogic.Queries
{
	public class OrderViewQuery : ICannedQuery<OrderView>
	{
		private readonly OrderStatus _orderStatus;

		public OrderViewQuery(OrderStatus orderStatus)
		{
			_orderStatus = orderStatus;
		}

		public IEnumerable<OrderView> Execute(ISession session)
		{
			var query = session.CreateQuery(
				@"
					SELECT
						order.OrderStatus.Name AS OrderStatus,
						order.Customer.FirstName AS CustomerFirstName,
						order.Customer.LastName AS CustomerLastName,
						order.Customer.EmailAddress AS CustomerEmail,
						order.OrderNumber AS OrderNumber,
						order.OrderTotal AS OrderTotal,
						order.ProductCatalogGroup.Name AS StoreName
					FROM PurchaseOrder order
					WHERE order.OrderStatus = :orderStatus
				")
					.SetResultTransformer(new AliasToBeanResultTransformer(typeof(OrderView)))
					.SetParameter("orderStatus",_orderStatus)
					.Future<OrderView>()
					.ToList();

			return query;
		}
	}
}
