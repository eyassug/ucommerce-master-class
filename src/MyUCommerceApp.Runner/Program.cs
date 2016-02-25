using System;
using System.Collections.Generic;
using System.Linq;
using MyUCommerceApp.BusinessLogic.Queries;
using MyUCommerceApp.BusinessLogic.Queries.ViewModel;
using NHibernate;
using NHibernate.Linq;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;
using UCommerce.Transactions;
using UCommerce.Transactions.Payments;

namespace MyUCommerceApp.Integration
{
	class OrderLineProduct
	{
		public string OrderNumber { get; set; }

		public Product Product { get; set; }

		public OrderLine OrderLine { get; set; }
	}
	class Program
	{
		static void Main(string[] args)
		{
//			var queryDate = DateTime.Now.AddYears(-1);
//
//			//Using UCommerce.EntitiesV2.Purchase.All()
//			IList<UCommerce.EntitiesV2.PurchaseOrder> orders
//				= UCommerce.EntitiesV2.PurchaseOrder
//					.All()
//					.Where(order => order.CompletedDate > queryDate)
//					.ToList();
//			
//			//Grabbing a repository and doing the same query
//			IRepository<UCommerce.EntitiesV2.PurchaseOrder> orderRepository =
//				ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
//
//			IList<UCommerce.EntitiesV2.PurchaseOrder> ordersFromRepository =
//				orderRepository.Select(order => order.CompletedDate > queryDate).ToList();
//
//			//Grabbing a session directly from the ISessionProvider
//			ISessionProvider sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
//
//			IList<UCommerce.EntitiesV2.PurchaseOrder> ordersFromSession =
//				sessionProvider
//					.GetSession()
//					.Query<UCommerce.EntitiesV2.PurchaseOrder>()
//					.Where(x => x.CompletedDate > queryDate).ToList();

//			var productsOnHomepage = ObjectFactory.Instance.Resolve<IRepository<Product>>()
//					.Select(new ProductByPropertiesQuery("ShowOnHomepage", "True"))
//					.ToList();
//
//			var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
//			using (ISession session = sessionProvider.GetSession())
//			{
//				var result = new ProductByPropertiesQuery("ShowOnHomepage", "True").Execute(session);
//			}
//
//			var productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
//			var orderLineRepository = ObjectFactory.Instance.Resolve<IRepository<OrderLine>>();
//
//			var productsOnOrderLine = 
//				from orderLine in orderLineRepository.Select()
//				join product in productRepository.Select()
//					on new { orderLine.Sku, orderLine.VariantSku } equals
//					new { product.Sku, product.VariantSku }
//				select new OrderLineProduct()
//				{
//					OrderLine = orderLine,
//					Product = product,
//					OrderNumber = orderLine.PurchaseOrder.OrderNumber
//				};
//
//			foreach (OrderLineProduct productOnOrderLine in productsOnOrderLine)
//			{
//				Console.WriteLine(
//					productOnOrderLine.Product.Name + string.Format(" bought on order: {0}", productOnOrderLine.OrderNumber));
//			}

//			var orders = PurchaseOrder.All().ToList(); //1 query to load up the orders + a query for the amount of orders in my collection.

			//1-1 relation between billingAddress and the order and the Customer and the order
//			var orders = PurchaseOrder.All().Fetch(x => x.Customer).Fetch(x => x.BillingAddress).ToList();
//			foreach (var purchaseOrder in orders)
//			{
//				var customer = purchaseOrder.Customer;
//				if (customer != null)
//				{
//					Console.WriteLine(customer.FirstName);					
//				}
//			}
//
//			var product = Product
//							.All()
//							.Where(x => x.ProductId == 105)
//							.FetchMany(x => x.Variants)
//							.FetchMany(x => x.ProductRelations)
//							.FetchMany(x => x.ProductDescriptions).ToList();
//
//			Product.All().Where(x => x.ProductId == 105).FetchMany(x => x.Variants).ToList();
//
//			Product.All().Where(x => x.ProductId == 105).FetchMany(x => x.ProductRelations).ToList();

//			var orderStatus = OrderStatus.Get((int) OrderStatusCode.NewOrder);
//			var result = ObjectFactory.Instance.Resolve<IRepository<OrderViewModel>>().Select(new OrderViewQuery(orderStatus)).ToList();

		}
	}
}
