using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.BusinessLogic.Queries
{
	public class ProductsWithVariantsQuery : ICannedQuery<Product>
	{
		public IEnumerable<Product> Execute(ISession session)
		{
			var query =  session.CreateQuery(
				@"
					select product from Product product
					left join fetch product.Variants
				").Future<Product>();

			return query.ToList();
		}
	}
}
