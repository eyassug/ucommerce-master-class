using System;
using System.Collections.Generic;
using System.Linq;
using MyUCommerceApp.BusinessLogic.Queries;
using NHibernate;
using NHibernate.Linq;
using NHibernate.Transform;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;
using UCommerce.Transactions;

namespace MyUCommerceApp.Integration
{
	class Program
	{
		static void Main(string[] args)
		{
//			IQueryable<PurchaseOrder> queryable = UCommerce.EntitiesV2.PurchaseOrder.All();
//			var orders = queryable.Where(order => order.CompletedDate > new DateTime(2015, 1, 1)).ToList();
//			IRepository<PurchaseOrder> orderRepository = UCommerce.Infrastructure.ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
//
//			IQueryable<PurchaseOrder> orderQuery = orderRepository.Select();
//
//			var ordersFromRepository = orderQuery.Where(order => order.CompletedDate > new DateTime(2015, 1, 1)).ToList();
//
//			ISessionProvider sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
//
//			ISession session = sessionProvider.GetSession();
//
//			IQueryable<PurchaseOrder> query = session.Query<PurchaseOrder>();
//			query.Where(x => x.Customer != null).ToList();

//			IRepository<Product> productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
//
//			IEnumerable<Product> products = productRepository.Select(new ProductByPropertiesQuery("true", "ShowOnHomepage"));

//			IRepository<PurchaseOrder> orderRepository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();

			//HasBillingAddress will fail as not mapped through NHibernate
			//var orders = orderRepository.Select(order => order.HasBillingAddress).ToList();

			//N+1 problem
//			IRepository<PurchaseOrder> orderRepository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
			
//			var orders = orderRepository.Select()
//							.Fetch(x => x.OrderLines)
//							.Fetch(x => x.Customer)
//							.ToList();
//
//			foreach (var purchaseOrder in orders)
//			{
//				if (purchaseOrder.Customer != null)
//				{
//					var customerFirstName = purchaseOrder.Customer.FirstName;					
//				}
//			}

			//The fix here is to use fetch!
//			IRepository<Product> productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
//			var variants = productRepository
//								.Select(x => x.ProductId == 105)
//									.FetchMany(x => x.Variants)
//									.FetchMany(x => x.ProductRelations)
//									.FetchMany(x => x.CategoryProductRelations).ToList();


//			var products = Product.All().Where(x => x.ParentProduct == null).ToList();
////
//			var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
//			
//			var variants = sessionProvider.GetSession().CreateQuery(
//			@"
//				SELECT 
//					p 
//				FROM Product p
//				WHERE p.ParentProduct in (:products)
//			").SetParameterList("products", products).Future<Product>().ToList();

//			var orderViewModel = ObjectFactory.Instance.Resolve<IRepository<OrderViewModel>>();
//			var orders = orderViewModel.Select(new OrderViewQuery(OrderStatus.Get((int) OrderStatusCode.NewOrder))).ToList();

			//entities are connected to the database per the fact that we have lazy loading!
			//lazy loaded properties are proxy objects that are connected to a session

			var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();

			Product product = null;
			using (var session = sessionProvider.GetSession())
			{
				//session.Get<Product>(105);
				product = Product.Get(105); 				
			}

			var sku = product.Sku;

			var variants = product.Variants.ToList();
			//forbidden to keep a static list of entities in memory because the session is disposed after the HttpRequest
			//you will run into lazy loading exception
		}
	}
}
