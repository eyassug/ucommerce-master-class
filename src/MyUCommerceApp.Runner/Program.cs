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
            //var ordersByCertianDateFromStaticLayer = UCommerce.EntitiesV2.PurchaseOrder
            //          .All()
            //          .Where(purchaseOrder => purchaseOrder.CompletedDate > new DateTime(2009,1,1))
            //          .ToList();


            //var repository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
            //var ordersByCertianDateFromRepository = repository
            //          .Select()
            //          .Where(purchaseOrder => purchaseOrder.CompletedDate > new DateTime(2009, 1, 1))
            //          .ToList();


            //      ISessionProvider sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
            //var ordersByCertianDateFromSessionProvider = sessionProvider
            //          .GetSession()
            //          .Query<PurchaseOrder>()
            //          .Where(purchaseOrder => purchaseOrder.CompletedDate > new DateTime(2009, 1, 1))
            //          .ToList();

            //      var productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
            //var productsOnHomePage = productRepository
            //          .Select(new ProductsByPropertiesQuery("ShowOnHomePage", "True"))
            //          .ToList();


            //1 query to load up the orders from the database
            //N = Numbers in the collections
            //N+1 = 1 query per relation we access.  
            //Fetch prevents N+1
            //using statements on the website is bad. 
            //var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
            //IList<PurchaseOrder> orders;
            //using (var session = sessionProvider.GetSession())
            //{
            //    orders = session.Query<PurchaseOrder>().Fetch(x => x.Customer).ToList();
            
            //    foreach (var purchaseOrder in orders)
            //    {
            //        if (purchaseOrder.Customer != null)
            //        {
            //            Console.WriteLine(purchaseOrder.Customer.FirstName + " - " + purchaseOrder.BillingAddress.CompanyName);
            //        }
            //    }
            //}

            var product = ObjectFactory.Instance.Resolve<IRepository<Product>>()
                .Select(x => x.ProductId == 105)
                .FetchMany(x => x.Variants)
                .FetchMany(x => x.CategoryProductRelations)
                .FetchMany(x => x.ProductRelations)
                .ToList();

            Console.ReadLine();
        }
    }
}

