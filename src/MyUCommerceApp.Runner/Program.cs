using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using MyUCommerceApp.BusinessLogic.Queries;
using NHibernate;
using NHibernate.Exceptions;
using NHibernate.Linq;
using NHibernate.Transform;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;
using UCommerce.Transactions;

namespace MyUCommerceApp.Integration
{
	class Program
	{
		private static void Main(string[] args)
		{
//			IRepository<PurchaseOrder> repository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
//			var order = repository.Select(new LatestOrderQuery()).First();

//			IList<UCommerce.EntitiesV2.PurchaseOrder> orders = PurchaseOrder.All().ToList();
//
//			var productRepo = ObjectFactory.Instance.Resolve<IRepository<Product>>();

//			UCommerce.EntitiesV2.Product product = UCommerce.EntitiesV2.Product.All().First();

//			ISessionProvider sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
//
//			using (var session = sessionProvider.GetSession())
//			{
//				session.Query<Product>().Where(x => x.ParentProduct == null).ToList();
//			}

//			IRepository<PurchaseOrder> orderRepository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
//
//			IQueryable<PurchaseOrder> orderQuery = orderRepository.Select();
//
//			IList<PurchaseOrder> orders = orderQuery.Where(x => x.CreatedDate > new DateTime(2015, 01, 01)).ToList();

//			var productRepo = ObjectFactory.Instance.Resolve<IRepository<Product>>();

			//IQueryable is deffered executed!!!!!
//			IQueryable<Product> productQuery = 
//				productRepo
//					.Select(product => product.ProductProperties.Any(
//									property => 
//											property.Value == "true" && 
//											property.ProductDefinitionField.Name == "ShowOnHomepage"));
//			
//			var result = productQuery.ToList();

//			var customer = Customer.All().FirstOrDefault();

//			var ordersForCustomer = PurchaseOrder.All().Where(order => order.Customer == customer);

//			var lineRepository = ObjectFactory.Instance.Resolve<IRepository<OrderLine>>();
//			var productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
//
//			var query = 
//				from orderLine in lineRepository.Select()
//				join product in productRepository.Select()
//						on new {orderLine.Sku, orderLine.VariantSku} 
//					equals
//						new {product.Sku, product.VariantSku}
//				select new {Product = product, OrderLine = orderLine};
//

			var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
//
			//will give us n+1 problems
//			using (var session = sessionProvider.GetSession())
//			{
//				var orders = session.Query<PurchaseOrder>().ToList();
//
//				//N+1 queries
//				foreach (var purchaseOrder in orders)
//				{
//					if (purchaseOrder.Customer != null)
//					{
//						var customer = purchaseOrder.Customer;
//						var firstName = customer.FirstName;
//					}
//				}
//			}

			//solution to the n+1 problem
//			using (var session = sessionProvider.GetSession())
//			{
//				var orders = session
//					.Query<PurchaseOrder>()
//						.Fetch(order => order.Customer).ToList();
//
//				foreach (var purchaseOrder in orders)
//				{
//					if (purchaseOrder.Customer != null)
//					{
//						var customer = purchaseOrder.Customer;
//						var firstName = customer.FirstName;
//					}
//				}
//			}

//			using (var session = sessionProvider.GetSession())
//			{
//				var products = session.Query<Product>()
//					.FetchMany(product => product.Variants)
//					.FetchMany(product => product.ProductRelations)
//					.Where(product => product.ProductId == 105).ToList();
//			}

//			List<string> skus = Product.All().Select(x => x.Sku).ToList();

			var orderStatus = OrderStatus.Get((int) OrderStatusCode.NewOrder);
			using (var session = sessionProvider.GetSession())
			{
				var result = session.CreateQuery(
				@"
					SELECT
						order.OrderStatus.Name AS		OrderStatus,
						order.Customer.FirstName AS		CustomerFirstName,
						order.Customer.EmailAddress AS	CustomerEmail,
						order.OrderTotal AS				OrderTotal
					FROM PurchaseOrder order
					WHERE order.OrderStatus = :orderStatus
				")
					.SetParameter("orderStatus",orderStatus)
					.SetResultTransformer(
						new AliasToBeanResultTransformer(typeof(OrderView)))
					.Future<OrderView>()
					.ToList();
			}
		}
	}
}
