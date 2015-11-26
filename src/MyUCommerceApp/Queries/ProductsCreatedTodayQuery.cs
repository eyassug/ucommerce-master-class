using System;
using System.Collections.Generic;
using System.Linq;
using NHibernate;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.BusinessLogic.Queries
{
    public class ProductsCreatedTodayQuery : ICannedQuery<Product>
    {
        public IEnumerable<Product> Execute(ISession session)
        {
            var activeRecordProducts = (from p in Product.All()
                           where p.CreatedOn >= DateTime.Now.Date
                           select p);

            
            var linqProducts = (from p in session.Query<Product>()
                                where p.CreatedOn >= DateTime.Now.Date
                                select p);

            var eagerProducts =
                session.QueryOver<Product>()
                    .Where(x => x.CreatedOn >= DateTime.Now.Date)
                    .Fetch(x => x.Variants).Eager
                    .Fetch(x => x.ProductDefinition).Eager
                    .List();

            var hqlProducts = session.CreateQuery("select p from Product p")
                .Future<Product>();

            var variants = session.CreateQuery(
                @"select p from Product p
                  left join fetch p.Variants")
                .Future<Product>();

            hqlProducts.ToList();

            return eagerProducts;
        }
    }
}