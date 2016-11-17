using System;
using System.Collections;
using System.Collections.Generic;
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
			//IList<PurchaseOrder> firstOrder = UCommerce.EntitiesV2.PurchaseOrder.All()
			//	.Where(x => x.CompletedDate > new DateTime(2009,1,1))
			//	.ToList();
			
	
			//var repository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
			//repository.Select()
			//	.Where(x => x.CompletedDate > new DateTime(2009,1,1))
			//	.ToList();


			//ISessionProvider sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
			//sessionProvider.GetSession()
			//	.Query<UCommerce.EntitiesV2.PurchaseOrder>()
			//	.Where(x => x.CompletedDate > new DateTime(2009, 1, 1))
			//	.ToList();


			//var productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
			//var productsOnHomePage = productRepository
			//						.Select(new ProductsByPropertiesQuery("ShowOnHomePage", "True"))
			//						.ToList();

			
			//1 query to load up the orders from the database
			//N = numbers in the collection
			//N+1 = 1 query to load up data + 1 query per relation we access

			//Fetch prevents N+1
			//var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
			//IList<PurchaseOrder> orders;
			////using statements on the website is bad. 
			//using (var session = sessionProvider.GetSession())
			//{
			//	orders = session.Query<PurchaseOrder>().Fetch(x => x.Customer).ToList();

			//	foreach (var purchaseOrder in orders)
			//	{
			//		if (purchaseOrder.Customer != null)
			//		{
			//			Console.WriteLine(purchaseOrder.Customer.FirstName);
			//			Console.WriteLine(purchaseOrder.BillingAddress.CompanyName);
			//		}
			//	}
			//}

			var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();

			sessionProvider.GetSession()
				.Query<Product>()
				.Where(product => product.ProductId == 105)
				.FetchMany(product => product.Variants)
				.FetchMany(product => product.CategoryProductRelations)
				.FetchMany(product => product.ProductRelations)
				.ToList();
			

			Console.ReadLine();
		}
	}
}
