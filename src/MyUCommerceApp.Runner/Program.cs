using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using MyUCommerceApp.BusinessLogic.Queries;
using NHibernate.Linq;
using Rhino.Mocks;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;
using UCommerce.Search.RavenDB;

namespace MyUCommerceApp.Integration
{
    class Program
    {
        static void Main(string[] args)
        {
            //var ordersByCertainDateFromStaticLayer = UCommerce.EntitiesV2.PurchaseOrder
            //    .All()
            //    .Where(x => x.CompletedDate > new DateTime(2009, 1, 1))
            //    .ToList();

            //IRepository<PurchaseOrder> repository = ObjectFactory.Instance.Resolve<IRepository<PurchaseOrder>>();
            //var ordersByCertainDateFromRepository = repository
            //    .Select()
            //    .Where(x => x.CompletedDate > new DateTime(2009, 1, 1))
            //    .ToList();

            //ISessionProvider sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
            //var ordersByCertainDateFromSessionProvider = sessionProvider
            //    .GetSession()
            //    .Query<UCommerce.EntitiesV2.PurchaseOrder>()
            //    .Where(x => x.CompletedDate > new DateTime(2009, 1, 1))
            //    .ToList();

            //var productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
            //var productsOnHomePage = productRepository.Select(new ProductsByPropertiesQuery("ShowOnHomePage", "true")).ToList();

            //1 query to load up the order from the database
            //N = Numbers in the collection.  
            //N+1 = 1 query to laod up data + 1 query per relation we access. 
            //Fetch prevents N+1
            //Using statement on the website is bad. 
            var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
            using (var session = sessionProvider.GetSession())
            {
                var orders = session.Query<PurchaseOrder>().ToList();

                foreach (var order in orders)
                {
                    if (order.Customer != null)
                    {
                        Console.WriteLine(order.Customer.FirstName);
                    }
                }
            }
            using (var session = sessionProvider.GetSession())
            {
                var orders2 = session.Query<PurchaseOrder>().ToList();

                foreach (var order in orders2)
                {
                    if (order.Customer != null)
                    {
                        Console.WriteLine(order.Customer.FirstName);
                    }
                }
            }

            //Level 1 cache = session
            //level 2 cache = sys cache 

            //var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();
            //sessionProvider.GetSession()
            //    .Query<Product>()
            //    .Where(product => product.ProductId == 105)
            //    .FetchMany(x => x.Variants) //4
            //    .FetchMany(x => x.CategoryProductRelations) //4
            //    .FetchMany(x => x.ProductRelations) //4
            //    .ToList();

            Console.ReadLine();
        }
    }
}
