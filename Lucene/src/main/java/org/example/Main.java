package org.example;

import org.apache.lucene.analysis.en.EnglishAnalyzer;
import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.*;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.ByteBuffersDirectory;
import org.apache.lucene.store.Directory;

import java.io.IOException;

public class Main {
    private static Document buildDoc(String title, String isbn) {
        Document doc = new Document();
        doc.add(new TextField("title", title, Field.Store.YES));
        doc.add(new StringField("isbn", isbn, Field.Store.YES));
        return doc;
    }

    public static void main(String[] args) throws IOException, ParseException {
//        StandardAnalyzer analyzer = new StandardAnalyzer();
//        EnglishAnalyzer analyzer = new EnglishAnalyzer();
        PolishAnalyzer analyzer = new PolishAnalyzer();
        Directory directory = new ByteBuffersDirectory();
        IndexWriterConfig config = new IndexWriterConfig(analyzer);
        IndexWriter w = new IndexWriter(directory, config);
//        w.addDocument(buildDoc("Lucene in Action", "9781473671911"));
//        w.addDocument(buildDoc("Lucene for Dummies", "9780735219090"));
//        w.addDocument(buildDoc("Managing Gigabytes", "9781982131739"));
//        w.addDocument(buildDoc("The Art of Computer Science",
//                "9781250301695"));
//        w.addDocument(buildDoc("Dummy and yummy title", "9780525656161"));
        w.addDocument(buildDoc("Lucyna w akcji", "9780062316097"));
        w.addDocument(buildDoc("Akcje rosną i spadają", "9780385545955"));
        w.addDocument(buildDoc("Bo ponieważ", "9781501168007"));
        w.addDocument(buildDoc("Naturalnie urodzeni mordercy",
                "9780316485616"));
        w.addDocument(buildDoc("Druhna rodzi", "9780593301760"));
        w.addDocument(buildDoc("Urodzić się na nowo", "9780679777489"));
        w.close();

//        String querystr = "*:*";

// ------ 7a ----------------------------------------------------------------
//        Result: 1. 9780525656161	Dummy and yummy title
//        String querystr = "title:dummy";

// ------ 7b ----------------------------------------------------------------
//        Result: 1. 9780525656161	Dummy and yummy title
//        String querystr = "title:and";

// ------ 9a ----------------------------------------------------------------
//        Result (7a):
//          1. 9780735219090	Lucene for Dummies
//          2. 9780525656161	Dummy and yummy title
//        Result (7b): Found 0 matching docs.

//        EnglishAnalyzer podczas analizowania zapytania bierze pod uwagę zasadny języka angielskiego.
//        Nie wyszukuje ciągu znaków tylko konkretne słowo, uwzględniając możliwość jego wariantów (np. liczba mnoga).


// ------ 12a ----------------------------------------------------------------
//        Result: 1. 9780062316097	Lucyna w akcji
//        String querystr = "isbn:\"9780062316097\"";

// ------ 12b ----------------------------------------------------------------
//        Result:
//          1. 9780679777489	Urodzić się na nowo
//          2. 9780316485616	Naturalnie urodzeni mordercy
//        String querystr = "title:urodzić";

// ------ 12c ----------------------------------------------------------------
//        Result: Found 0 matching docs.
//        String querystr = "title:rodzić";

// ------ 12d ----------------------------------------------------------------
//        Result:
//          1. 9780385545955	Akcje rosną i spadają
//          2. 9780593301760	Druhna rodzi
//        String querystr = "title:ro*";

// ------ 12e ----------------------------------------------------------------
//        Result: Found 0 matching docs.
//        String querystr = "title:ponieważ";

// ------ 12f ----------------------------------------------------------------
//        Result: 1. 9780062316097	Lucyna w akcji
//        String querystr = "title:Lucyna AND title:akcja";

// ------ 12g ----------------------------------------------------------------
//        Result: 1. 9780385545955	Akcje rosną i spadają
//        String querystr = "title:akcja NOT title:Lucyna";

// ------ 12h ----------------------------------------------------------------
//        Result: 1. 9780316485616	Naturalnie urodzeni mordercy
//        String querystr = "title:\"naturalnie morderca\"~2";

// ------ 12i ----------------------------------------------------------------
//        Result: 1. 9780316485616	Naturalnie urodzeni mordercy
//        String querystr = "title:\"naturalnie morderca\"~1";

// ------ 12j ----------------------------------------------------------------
//        Result: Found 0 matching docs.
//        String querystr = "title:\"naturalnie morderca\"~0";

// ------ 12k ----------------------------------------------------------------
//        Result: 1. 9780316485616	Naturalnie urodzeni mordercy
//        String querystr = "title:naturalne";

// ------ 12l ----------------------------------------------------------------
//        Result: 1. 9780316485616	Naturalnie urodzeni mordercy
        String querystr = "title:naturalne~2"; // Tolerancja dwóch literówek

        Query q = new QueryParser("title", analyzer).parse(querystr);
        int maxHits = 10;
        IndexReader reader = DirectoryReader.open(directory);
        IndexSearcher searcher = new IndexSearcher(reader);
        TopDocs docs = searcher.search(q, maxHits);
        ScoreDoc[] hits = docs.scoreDocs;

        System.out.println("Found " + hits.length + " matching docs.");
        StoredFields storedFields = searcher.storedFields();
        for(int i=0; i<hits.length; ++i) {
            int docId = hits[i].doc;
            Document d = storedFields.document(docId);
            System.out.println((i + 1) + ". " + d.get("isbn")
                    + "\t" + d.get("title"));
        }

        reader.close();
    }
}