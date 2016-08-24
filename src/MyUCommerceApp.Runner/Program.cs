using System;
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
            //            IRepository<PurchaseOrder> repository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
            //            ISessionProvider sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
            //
            //            IList<PurchaseOrder> 
            //                ordersByCertainDateFromStaticlayer = PurchaseOrder
            //                    .All()
            //                    .Where(x => x.CompletedDate > new DateTime(2009, 1, 1))
            //                    .ToList();
            //            
            //            IList<PurchaseOrder> orderFromRepo = repository
            //                    .Select(x => x.CompletedDate > new DateTime(2009, 1, 1))
            //                    .ToList();
            //
            //            var ordersFromSessionProvider = sessionProvider.GetSession()
            //		            .Query<UCommerce.EntitiesV2.PurchaseOrder>()
            //		            .Where(x => x.CompletedDate > new DateTime(2009, 1, 1))
            //		            .ToList();
            //            IRepository<Product> productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
            //            var products = productRepository.Select(new ProductsQueryByProperties("ShowOnHomepage", "true")).ToList();

            //		    IList<PurchaseOrder> orders;
            //		    var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();

            //using statements in the website is bad!!
            //            using (var session = sessionProvider.GetSession())
            //		    {
            //1 query to load up the orders from the database.
            //N = number of orders in the collection
            //N+1 = 1 query to load up data + 1 query per relation we access.

            //Fetch prevents N+1 problems!!!!
            //		        orders = session.Query<PurchaseOrder>().Fetch(order => order.Customer).ToList();
            //                foreach (var purchaseOrder in orders)
            //                {
            //                    if (purchaseOrder.Customer != null)
            //                    {
            //                        Console.WriteLine(purchaseOrder.Customer.FirstName);
            //                        Console.WriteLine(purchaseOrder.BillingAddress.CompanyName);
            //                    }
            //                }
            //            }

//   		    var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
//		    sessionProvider
//                .GetSession()
//                .Query<Product>()
//                .Where(x => x.ProductId == 105)
//                .FetchMany(x => x.Variants)
//                .FetchMany(x => x.CategoryProductRelations)
//                .FetchMany(x => x.ProductRelations)
//                .ToList();

		    //Console.ReadLine();

		    var orders = ObjectFactory.Instance.Resolve<IRepository<OrderReport>>().Select(new OrderReportQuery()).ToList();
		}
    }
}
