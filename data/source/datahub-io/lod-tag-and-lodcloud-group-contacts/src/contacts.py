#3> <> prov:specializationOf <https://github.com/timrdf/lodcloud/tree/master/data/source/datahub-io/lod-tag-and-lodcloud-group-contacts/src/contacts.py>;
#3>    rdfs:seeAlso <https://github.com/timrdf/DataFAQs/wiki/FAqT-Service> .

import faqt
import ckanclient

import time

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

import csv

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
ns.register(sio='http://semanticscience.org/resource/')

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

      recovered_emails = {}
      try:
         with open('manual/emails.csv', 'rb') as csvfile:
            spamreader = csv.reader(csvfile, delimiter=',') #, quotechar='|')
            for row in spamreader:
               dataset_id = row[0]
               emails = []
               for c in 1,2,3:
                  if self.emailish(row[c]) and row[c] not in emails:
                     print dataset_id + ' <- ' + row[c] 
                     emails.append(row[c])
               recovered_emails[dataset_id] = emails
      except IOError:
         print 'WARNING: Could not find recovered emails at manual/emails.csv'

      self.ckan = self.getCKANAPI(input)
      base  = re.sub('/api$','',self.ckan.base_location) # e.g. http://datahub.io
      print 'processing ' + input.subject                # e.g. http://datahub.io/tag/lod
      label = re.sub('^.*/tag/','',input.subject)        # e.g. lod

      # Stolen from https://github.com/timrdf/DataFAQs/blob/master/services/sadi/core/select-datasets/by-ckan-group.py#L75
      #for dataset_id in self.ckan.group_entity_get('lodcloud')['packages']:
      #   print dataset_id + ' in lodcloud'
      #   self.ckan.package_entity_get(dataset_id)
      #   package = self.ckan.last_message
      #   if 'lod' not in package['tags']:
      #      print dataset_id + ' not tagged lod'

      Tag     = input.session.get_class(ns.MOAT['Tag'])
      Thing   = input.session.get_class(ns.OWL['Thing'])
      Dataset = output.session.get_class(ns.DCAT['Dataset'])
      CKANDataset = output.session.get_class(ns.DATAFAQS['CKANDataset'])
      missingContactR = Dataset()
      missingContactR.rdfs_comment = 'CKANDatasets that do not have contact information.'

      # Stolen and dumbed down from https://github.com/timrdf/DataFAQs/blob/master/services/sadi/core/select-datasets/by-ckan-tag.py#L199
      query = ''
      query = query + 'tags:' + label
      print 'package_search ' + query

      tagged_lod = {}
      self.ckan.package_search(query) # e.g. self.ckan.package_search('tags:lod+tags:helpme')
      tagged = self.ckan.last_message
      print 'package_search returned'
      for dataset in tagged['results']:
         #time.sleep(1)

         print
         print '  ' + dataset + ' -> ' + base + '/dataset/' + dataset
         ckan_uri = base + '/dataset/' + dataset
         ckanR = CKANDataset(ckan_uri)
         ckanR.tag_taggedWithTag.append(output)
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
               try:
                  print '      (' + package['author'] + ')',
               except UnicodeEncodeError:
                  print 'WARNING: unicode in maintainer'
            print

            print '    maintainer:',
            if 'maintainer_email' in package and package['maintainer_email'] is not None and self.emailish(package['maintainer_email']):
               print ' ' + package['maintainer_email'],
               if package['maintainer_email'] not in contacts:
                  contacts.append(package['maintainer_email'])
            if 'maintainer'       in package and package['maintainer'] is not None and len(package['maintainer']) > 0:
               try:
                  print ' (' + package['maintainer'] + ')',
               except UnicodeEncodeError:
                  print 'WARNING: unicode in maintainer'
            print

            if len(contacts) > 0:
               print '      contactable via ' + ", ".join(contacts)
               directory = directory + '/is-contactable'
               for contact in contacts:
                  mbox = Thing('mailto:'+contact)
                  ckanR.foaf_mbox.append(mbox)
            else:
               if dataset in recovered_emails and len(recovered_emails[dataset]) > 0:
                  print '  contact RECOVERED ' + ", ".join(recovered_emails[dataset])
                  directory = directory + '/is-contactable-by-recovery'
                  for contact in recovered_emails[dataset]:
                     mbox = Thing('mailto:'+contact)
                     ckanR.foaf_mbox.append(mbox)
               else:
                  print '  NOT contactable'
                  directory = directory + '/not-contactable'
                  missingContactR.sio_has_member.append(ckanR)

            questions = []
            in_lodcloud = False
            if 'lodcloud' in package['groups']:
               print '        in lodcloud group'
               in_lodcloud = True
               directory = directory + '/is-in-lodcloud'
            else:
               print '    NOT in lodcloud group'
               directory = directory + '/not-in-lodcloud'

            if not os.path.exists(directory):
               os.makedirs(directory)
 
            these_addresses = 'these addresses' if len(contacts) > 1 else 'this address'
            body = ''

            q = 1
            # NOT lodcloud publishers
            if 'lodcloud' not in package['groups']: 
               body = body + str(q) + ') Does the tag "lod" on the dataset '+dataset+' mean "Linked Open Data"?\n\n'            
               q = q + 1

            body = body + str(q) + ') What type of organization produced the dataset '+dataset+'?\n   (e.g., academic, commercial, government, personal, etc.) Please list all that apply.\n\n'
            q = q + 1
            body = body + str(q) + ') What tools were used to create and publish the dataset '+dataset+'?\n   (Please designate any tools that were developed in house and whether or not they are publicly available.)\n\n'
            q = q + 1
            body = body + str(q) + ') Did you publish any papers based on the dataset '+dataset+'?\n   Please list all pertinent papers.\n\n'
            q = q + 1
            body = body + str(q) + ') Are you aware of any applications that use the dataset '+dataset+'?\n   Please list any that you are aware of and how you found out about them.\n\n'
            q = q + 1

            # All publishers:
            if 'lodcloud' not in package['groups']: 
               # NOT lodcloud publishers
               body = body + str(q) + ') Did you tag the dataset '+dataset+' as "lod" to facilitate the inclusion in the LOD Cloud Diagram (http://lod-cloud.net)?\n\n'
               q = q + 1
               body = body + str(q) + ") Did you try to fulfill the lodcloud group's metadata requirements for the dataset "+dataset+"?\n   (http://www.w3.org/wiki/TaskForces/CommunityProjects/LinkingOpenData/DataSets/CKANmetainformation)\n   If so, how difficult was it on a scale from 1 (very easy) to 10 (very difficult)?\n\n"
               q = q + 1
               body = body + str(q) + ") Did you use the lodcloud validator (http://validator.lod-cloud.net/validate.php) to help fulfill\n   the lodcloud group's metadata requirements for dataset "+dataset+"?\n   If so, how helpful was it on a scale from 1 (not helpful) to 10 (very helpful)?\n\n"
               q = q + 1

            else:
               # lodcloud publishers
               body = body + str(q) + ") On a scale from 1 (very difficult) to 10 (very easy), how easy was it to fulfill the lodcloud group's metadata requirements\n   for the dataset "+dataset+" (http://www.w3.org/wiki/TaskForces/CommunityProjects/LinkingOpenData/DataSets/CKANmetainformation)?\n\n"
               q = q + 1
               sp = ' ' if q > 9 else ''
               body = body + str(q) + ') On a scale from 1 (unhelpful) to 10 (very helpful), how helpful was the lodcloud validator\n'+sp+'   http://validator.lod-cloud.net/validate.php in helping you fulfill the lodcloud group\'s\n'+sp+'   metadata requirements for dataset '+dataset+'?\n\n'
               q = q + 1

            # All publishers:
            sp = ' ' if q > 9 else ''
            body = body + str(q) + ') Is the dataset '+dataset+' still being maintained?\n   '+sp+'If it is not, please explain why. (e.g., project funding ended, original objective was achieved, lost interest, etc.)\n\n'
            q = q + 1
            sp = ' ' if q > 9 else ''
            body = body + str(q) + ') On a scale from 1 (most easy) to 10 (very difficult), how difficult do you think it would be\n'+sp+'   for another expert developer to reproduce the Linked Data in dataset '+dataset+'?\n\n'
            q = q + 1
            sp = ' ' if q > 9 else ''
            body = body + str(q) + ') What factors would make it easy or difficult to reproduce the dataset '+dataset+'?\n  '+sp+' (e.g., availability of the original data, provenance available within the Linked Data itself,\n'+sp+'   domain expertise, thoroughness of documentation, or the tools that were used).\n\n'
            q = q + 1
            sp = ' ' if q > 9 else ''
            body = body + str(q) + ') Would you like to see a new version of the LOD Cloud Diagram (http://lod-cloud.net)?\n '+sp+'  Why or why not?\n\n'

            body = '''Hello,

My name is Tim Lebo and I'm conducting a survey about Linked Data datasets on datahub.io.
I'm contacting you because you are listed as an author or maintainer of the dataset '''+ckan_uri+'''.

Could you please take a few moments to answer the following '''+str(q)+''' questions?
For your convenience, you can just reply directly to this email.

I'm planning to release the survey results with a CC Zero license [1] at [2].
I won't include your email, and I'll associate your responses to the dataset (not you).
If this raises concerns for you, please let me know.

Thanks so much for your consideration.

Regards,
Tim Lebo

[1] http://creativecommons.org/publicdomain/zero/1.0/
[2] https://github.com/timrdf/lodcloud/wiki/Survey-1-2013-Jun-22


''' + body
#BTW, if you're involved with more than one dataset, my apologies for contacting you about each specific one.
#If there isn't really a difference between this dataset and another one of yours, please let me know.
            f = open(directory+'/'+dataset+'.txt', 'w')
            f.write(', '.join(contacts)+'\n')
            f.write('Some questions about your dataset '+dataset+'\n')
            f.write(body)
            f.close()
            ckanR.save()

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

      missingContactR.save()
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
