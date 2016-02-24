using System.Collections.Generic;
using System.Linq;
using NHibernate;
using NHibernate.Linq;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Queries
{
	public class ProductByPropertiesQuery : UCommerce.EntitiesV2.Queries.ICannedQuery<UCommerce.EntitiesV2.Product>
	{
		private readonly string _propertyName;
		private readonly string _propertyValue;

		public ProductByPropertiesQuery(string propertyName, string propertyValue)
		{
			_propertyName = propertyName;
			_propertyValue = propertyValue;
		}

		public IEnumerable<Product> Execute(ISession session)
		{
			return session
				.Query<UCommerce.EntitiesV2.Product>()
				.Where(
					product =>
						product.ProductProperties
						.Any(
								productProperty =>
									productProperty.Value == _propertyValue && 
									productProperty.ProductDefinitionField.Name == _propertyName))
				.ToList();
		}
	}
}
