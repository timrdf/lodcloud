#3> <> prov:specializationOf <https://github.com/timrdf/lodcloud/tree/master/data/source/datahub-io/lod-tag-and-lodcloud-group-contacts/src/contacts.py>;
#3>    rdfs:seeAlso <https://github.com/timrdf/DataFAQs/wiki/FAqT-Service> .

import faqt
import ckanclient

import sadi
from rdflib import *
import surf

from surf import *
from surf.query import a, select

import rdflib
rdflib.plugin.register('sparql', rdflib.query.Processor,
                       'rdfextras.sparql.processor', 'Processor')
rdflib.plugin.register('sparql', rdflib.query.Result,
                       'rdfextras.sparql.query', 'SPARQLQueryResult')

import httplib
from urlparse import urlparse, urlunparse
import urllib
import urllib2

# These are the namespaces we are using beyond those already available
# (see http://packages.python.org/SuRF/modules/namespace.html#registered-general-purpose-namespaces)
ns.register(moat='http://moat-project.org/ns#')
ns.register(ov='http://open.vocab.org/terms/')
ns.register(void='http://rdfs.org/ns/void#')
ns.register(dcat='http://www.w3.org/ns/dcat#')
ns.register(sd='http://www.w3.org/ns/sparql-service-description#')
ns.register(conversion='http://purl.org/twc/vocab/conversion/')
ns.register(datafaqs='http://purl.org/twc/vocab/datafaqs#')
ns.register(tag='http://www.holygoat.co.uk/owl/redwood/0.1/tags/')

# The Service itself
class LODTagAndLODCloudGroupContacts(faqt.CKANReader):

   # Service metadata.
   label                  = 'LOD Tag and LOD Cloud Group Contacts'
   serviceDescriptionText = 'Gathers the contact information for dataset contacts.'
   comment                = ''
   serviceNameText        = 'contacts' # Convention: Match 'name' below.
   name                   = 'contacts' # This value determines the service URI relative to http://localhost:9090/
                                       # Convention: Use the name of this file for this value.
   dev_port = 9241

   def __init__(self):
      # DATAFAQS_PROVENANCE_CODE_RAW_BASE                   +  servicePath  +  '/'  + self.serviceNameText
      # DATAFAQS_PROVENANCE_CODE_PAGE_BASE                  +  servicePath  +  '/'  + self.serviceNameText
      #
      # ^^ The source code location
      #    aligns with the deployment location \/
      #
      #                 DATAFAQS_BASE_URI  +  '/datafaqs/'  +  servicePath  +  '/'  + self.serviceNameText
      faqt.Service.__init__(self, servicePath = 'services/sadi') # TEMPLATE: used to get free provenance.
                                                                 # Use: pwd | sed 's/^.*services/services/'
   def getOrganization(self):
      result                      = self.Organization()
      result.mygrid_authoritative = True
      result.protegedc_creator    = 'lebot@rpi.edu'
      result.save()
      return result

   def getInputClass(self):
      return ns.TAG['Tag']

   def getOutputClass(self):
      return ns.TAG['Tag']

   def emailish(self, address):
      return re.match('[^@]+@[^@]+\.[^@]+',address) # http://stackoverflow.com/questions/8022530/python-check-for-valid-email-address
      
   # Assumes running from working directory e.g. lod-tag-and-lodcloud-group-contacts/version/2013-Jul-01
   def process(self, input, output):


      self.ckan = self.getCKANAPI(input)
      base  = re.sub('/api$','',self.ckan.base_location) # e.g. http://datahub.io
      print 'processing ' + input.subject                # e.g. http://datahub.io/tag/lod
      label = re.sub('^.*/tag/','',input.subject)        # e.g. lod

      Tag     = input.session.get_class(ns.MOAT['Tag'])
      Dataset = output.session.get_class(ns.DATAFAQS['CKANDataset'])

      # Stolen and dumbed down from https://github.com/timrdf/DataFAQs/blob/master/services/sadi/core/select-datasets/by-ckan-tag.py#L199
      query = ''
      query = query + 'tags:' + label
      print 'package_search ' + query

      tagged_lod = {}
      self.ckan.package_search(query) # e.g. self.ckan.package_search('tags:lod+tags:helpme')
      tagged = self.ckan.last_message
      print 'package_search returned'
      for dataset in tagged['results']:
         print
         print '  ' + dataset + ' -> ' + base + '/dataset/' + dataset
         ckan_uri = base + '/dataset/' + dataset
         tagged_lod[dataset] = ckan_uri
         #dataset = Dataset(ckan_uri)
         #dataset.rdf_type.append(ns.DATAFAQS['CKANDataset'])
         #dataset.rdf_type.append(ns.DCAT['Dataset'])
         #dataset.save()
         #output.dcterms_hasPart.append(dataset)
         #
         directory = 'source/tagged-' + label
         # GET the current dataset metadata listing from CKAN.
         package = {}
         try:
            self.ckan.package_entity_get(dataset)
            package = self.ckan.last_message
            contacts = []

            print '    author:',
            if 'author_email' in package and package['author_email'] is not None and self.emailish(package['author_email']):
               print ' ' + package['author_email'],
               contacts.append(package['author_email'])
            if 'author'       in package and package['author'] is not None and len(package['author']) > 0:
               print '      (' + package['author'] + ')',
            print

            print '    maintainer:',
            if 'maintainer_email' in package and package['maintainer_email'] is not None and self.emailish(package['maintainer_email']):
               print ' ' + package['maintainer_email'],
               contacts.append(package['maintainer_email'])
            if 'maintainer'       in package and package['maintainer'] is not None and len(package['maintainer']) > 0:
               print ' (' + package['maintainer'] + ')',
            print

            if len(contacts) > 0:
               print '      contactable via ' + "".join(contacts)
               directory = directory + '/contactable'
            else:
               print '  NOT contactable'
               directory = directory + '/not-contactable'

            in_lodcloud = False
            if 'lodcloud' in package['groups']:
               print '        in lodcloud group'
               in_lodcloud = True
               directory = directory + '/in-lodcloud'
            else:
               print '    NOT in lodcloud group'
               directory = directory + '/not-in-lodcloud'

            if not os.path.exists(directory):
               os.makedirs(directory)

            f = open(directory+'/'+dataset+'.txt', 'w')
            f.write('Hello, '+label)
            f.close()

         except ckanclient.CkanApiNotFoundError:
            print 'Error: could not get ckan dataset ' + dataset

      print str(len(tagged_lod))
      
      ####
      # Query a SPARQL endpoint
      #store = Store(reader = 'sparql_protocol', endpoint = 'http://dbpedia.org/sparql')
      #session = Session(store)
      #session.enable_logging = False
      #result = session.default_store.execute_sparql('select distinct ?type where {[] a ?type} limit 2')
      #if result:
      #   for binding in result['results']['bindings']:
      #      type  = binding['type']['value']
      #      print type
      ####

      # Query the RDF graph POSTed: input.session.default_store.execute

      # Walk through all Things in the input graph (using SuRF):
      # Thing = input.session.get_class(ns.OWL['Thing'])
      # for person in Thing.all():

      # Create a class in the output graph:
      # Document = output.session.get_class(ns.FOAF['Document'])

      #if True:
      #   output.rdf_type.append(ns.DATAFAQS['Unsatisfactory'])
 
      #if ns.DATAFAQS['Unsatisfactory'] not in output.rdf_type:
      #   output.rdf_type.append(ns.DATAFAQS['Satisfactory'])

      output.save()

# Used when Twistd invokes this service b/c it is sitting in a deployed directory.
resource = LODTagAndLODCloudGroupContacts()

# Used when this service is manually invoked from the command line (for testing).
#
# Usage: <input-rdf-file> [input-rdf-file-syntax] [output-rdf-file]
#
if __name__ == '__main__':

   if len(sys.argv) == 0:
      print resource.name + ' running on port ' + str(resource.dev_port) + '. Invoke it with:'
      print 'curl -H "Content-Type: text/turtle" -d @my.ttl http://localhost:' + str(resource.dev_port) + '/' + resource.name
      sadi.publishTwistedService(resource, port=resource.dev_port)

   else:
      reader = open(sys.argv[1],"r")
      mimeType = "application/rdf+xml"
      if len(sys.argv) > 2:
         mimeType = sys.argv[2]
      if len(sys.argv) > 3:
         writer = open(sys.argv[3],"w")

      graph = resource.processGraph(reader,mimeType)

      if len(sys.argv) > 3:
         writer.write(resource.serialize(graph,mimeType))
      else:
         print resource.serialize(graph,mimeType)
