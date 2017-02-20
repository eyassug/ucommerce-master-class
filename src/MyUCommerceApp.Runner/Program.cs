using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using MyUCommerceApp.BusinessLogic.Queries;
using NHibernate.Linq;
using NHibernate.Type;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;
using UCommerce.Search.RavenDB;

namespace MyUCommerceApp.Integration
{
    class Program
    {
        static void Main(string[] args)
        {
            //var ordersByCertianDateFromStaticLayer = UCommerce.EntitiesV2.PurchaseOrder
            //    .All()
            //    .Where(x => x.CompletedDate > new DateTime(2009, 1, 1))
            //    .ToList();

            //var repository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
            //var ordersByCertianDateFromRepository = repository
            //    .Select()
            //    .Where(x => x.CompletedDate > new DateTime(2009, 1, 1))
            //    .ToList();

            //ISessionProvider sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
            //var ordersByCertianDateFromSessionProvider = sessionProvider.GetSession()
            //    .Query<UCommerce.EntitiesV2.PurchaseOrder>()
            //    .Where(x => x.CompletedDate > new DateTime(2009, 1, 1))
            //    .ToList();

            //var repository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
            //var productsOnHomePage = repository
            //    .Select(new ProductsByPropertiesQuery("ShowOnHomepage", "True"))
            //    .ToList();


            //1 query to load up the orders from the database
            //N = Numbers in the collection
            //N+1 = 1 query to load up data + 1 qyery per relation we access. 

            //Fetch prevents N+1.

            //Using statement on the website is bad.
            //var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
            //using (var session = sessionProvider.GetSession())
            //{
            //    var orders = session.Query<PurchaseOrder>().Fetch(x => x.Customer).ToList();

            //    foreach (var purchaseOrder in orders)
            //    {
            //        if (purchaseOrder.Customer != null)
            //        {
            //            Console.WriteLine(purchaseOrder.Customer.FirstName);
            //        }
            //    }
            //}

            var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
            sessionProvider.GetSession()
                .Query<Product>()
                .Where(x => x.ProductId == 105)
                .FetchMany(x => x.Variants)
                .FetchMany(x => x.CategoryProductRelations)
                .FetchMany(x => x.ProductRelations)
                .ToList();

            Console.ReadLine();
        }
    }
}
