using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.Queries
{
	public class ProductsOnHomePageQuery : ICannedQuery<Product>
	{
		public IEnumerable<Product> Execute(ISession session)
		{
			var query = session.Query<Product>()
				.Where(
					product => product.ProductProperties.Any(
						property =>
							property.ProductDefinitionField.Name == "ShowOnHomepage" &&
							property.Value == "True"));

			return query.ToList();
		}
	}
}
