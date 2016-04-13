using System.Collections.Generic;
using System.Linq;
using NHibernate;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.BusinessLogic.Queries
{
	public class ProductByPropertiesQuery : ICannedQuery<UCommerce.EntitiesV2.Product>
	{
		private readonly string _propertyValue;
		private readonly string _propertyName;

		public ProductByPropertiesQuery(string propertyValue, string propertyName)
		{
			_propertyValue = propertyValue;
			_propertyName = propertyName;
		}

		public IEnumerable<Product> Execute(ISession session)
		{
			return session
				.Query<Product>()
				.Where(product => 
					product.ProductProperties.Any(
					property => property.Value == _propertyValue &&
								property.ProductDefinitionField.Name == _propertyName));
		}
	}
}
