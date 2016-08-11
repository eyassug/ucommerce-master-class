using System;
using System.Linq;
using MyUCommerceApp.BusinessLogic.Queries;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;

namespace MyUCommerceApp.Integration
{
	class Program
	{
		static void Main(string[] args)
		{

			//var products = session.CreateQuery(_productIds, @"
			//	select p from Product p
			//	where p.ProductId in ({0})")
			//.SetCacheable(_cachable)
			//.SetCacheRegion(cacheRegion)
			//.SetTimeout(TimeoutPeriod)
			//.Future<Product>();

			//session.CreateQuery(@"
			//	select p from Product p
			//	left outer join fetch p.ProductProperties pp
			//	where p.ProductId in ({0})")
			//.SetCacheable(_cachable)
			//.SetCacheRegion(cacheRegion)
			//.SetTimeout(TimeoutPeriod)
			//.Future<Product>();


		}

		private static void Fetch_While_Avoiding_Large_Cartesian_Product()
		{
			var orderRepository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();

			var orderlineRepository = ObjectFactory.Instance.Resolve<IRepository<OrderLine>>();

			var orderQuery = orderRepository
				.Select()
				.Where(x => x.BillingAddress != null).ToFuture();

			orderlineRepository.Select().Where(x => x.PurchaseOrder.BillingAddress != null).ToFuture();

			foreach (var order in orderQuery.ToList())
			{
				Console.WriteLine("{0} {1}", order.BillingAddress.FirstName, order.BillingAddress.LastName);

				Console.WriteLine(order.OrderLines.First().Sku);
			}

			Console.ReadLine();
		}

		private static void Join_Product_And_OrderLine()
		{
			var productRepo = ObjectFactory.Instance.Resolve<IRepository<Product>>();
			var orderlineRepo = ObjectFactory.Instance.Resolve<IRepository<OrderLine>>();

			var query = from orderline in orderlineRepo.Select()
				join product in productRepo.Select() on
					new {orderline.Sku, orderline.VariantSku} equals new {product.Sku, product.VariantSku}
				select new {OrderLine = orderline, Product = product};

			var orderlinesWithProducts = query.ToList();
		}

		private static void Query_By_Custom_Product_Properties()
		{
			var productRepo = ObjectFactory.Instance.Resolve<IRepository<Product>>();
			var query = productRepo.Select().Where(
				x => x.ProductProperties.Any(
					y => y.ProductDefinitionField.Name == "ShowOnHomepage" && y.Value == "True"));

			var productsOnFrontpage = query.ToList();
		}

		private static void Query_Orders_By_Date()
		{
			var orderRepository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
			IQueryable<PurchaseOrder> query = orderRepository.Select();

			var orders = query.Where(x => x.CompletedDate >= new DateTime(2016, 6, 7))
				.ToList();

			foreach (var order in orders)
			{
				var orderTotal = order.OrderTotal;
			}
		}

		private static void Canned_Query_Example()
		{
			var order = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>()
				.Select(new LatestOrderQuery()).First();
		}
	}
}
