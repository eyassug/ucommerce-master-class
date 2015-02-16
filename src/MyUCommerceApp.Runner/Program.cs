using System;
using System.Collections.Generic;
using System.Linq;
using MyUCommerceApp.BusinessLogic.Queries;
using MyUCommerceApp.BusinessLogic.Queries.ViewModel;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;
using UCommerce.Transactions;

namespace MyUCommerceApp.Integration
{
	class Program
	{
		static void Main(string[] args)
		{
//			var order = ObjectFactory
//				.Instance
//				.Resolve<IRepository<PurchaseOrder>>()
//				.Select(new LatestOrderQuery()).First();

//			var orders = PurchaseOrder.All().Where(x => x.Customer != null).ToList();

//			IQueryable<PurchaseOrder> query = PurchaseOrder.All();
//
//			IList<PurchaseOrder> result = query.ToList();
//
//			PurchaseOrder first = query.First();
//
//			IQueryable<PurchaseOrder> query2 = result.AsQueryable();

//			var productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();

//			var orderLineRepository = ObjectFactory.Instance.Resolve<IRepository<OrderLine>>();

//			var productsOnHomePage = productRepository.Select(new ProductsByPropertiesQuery("ShowOnHomePage", "True")).ToList();

//			IQueryable<OrderLine> query1 = orderLineRepository.Select(x => x.VariantSku != null);

//			var query2 =
//				from orderLine in orderLineRepository.Select()
//				join product in productRepository.Select()
//				on new { orderLine.Sku, orderLine.VariantSku } equals new { product.Sku, product.VariantSku }
//				select new { product, orderLine };
//
//			var result = query2.ToList();

//			var orderStatus = OrderStatus.Get((int) OrderStatusCode.NewOrder);
//
//			var repository = ObjectFactory.Instance.Resolve<IRepository<OrderView>>();
//
//			var result = repository.Select(new OrderViewQuery(orderStatus));
//			IList<PurchaseOrder> orders = 
//				orderRepository
//					.Select()
//					.Fetch(order => order.Customer)
//					.ToList();
//
//			foreach (var purchaseOrder in orders)
//			{
//				if (purchaseOrder.Customer != null)
//				{
//					var firstName = purchaseOrder.Customer.FirstName;
//				}
//			}
//
//			var products = Product.All().ToList();
//			
//			foreach (var product in products)
//			{
//				product.VariantSku = "bla";
//
//				product.Save();
//			}
//
//			var productRepo = ObjectFactory.Instance.Resolve<IRepository<Product>>();
//
//			foreach (var product in productRepo.Select())
//			{
//				product.Sku = "bla";
//
//				productRepo.Save(product);
//
//				var newProduct = new Product();
//				productRepo.Save(newProduct);
//			}
		}
	}
}
