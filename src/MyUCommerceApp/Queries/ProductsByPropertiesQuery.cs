using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.BusinessLogic.Queries
{
	public class ProductsByPropertiesQuery : ICannedQuery<Product>
	{
		private readonly string _propertyName;
		private readonly string _propertyValue;


		public ProductsByPropertiesQuery(string propertyName, string propertyValue)
		{
			_propertyName = propertyName;
			_propertyValue = propertyValue;
		}

		public IEnumerable<Product> Execute(ISession session)
		{
			//prop.ProductDefinitionField.Name //ShowOnHomePage
			//prop.Value //true

			IQueryable<Product> query = session.Query<Product>();

			return query.Where(product => product.ProductProperties.Any(
					productProperty =>
						productProperty.Value == _propertyValue && 
						productProperty.ProductDefinitionField.Name == _propertyName)).ToList();
		}
	}
}
