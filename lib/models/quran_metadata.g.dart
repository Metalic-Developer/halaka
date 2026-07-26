// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_metadata.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuranMetadataCollection on Isar {
  IsarCollection<QuranMetadata> get quranMetadatas => this.collection();
}

const QuranMetadataSchema = CollectionSchema(
  name: r'QuranMetadata',
  id: 2373223537891454788,
  properties: {
    r'ayaNo': PropertySchema(
      id: 0,
      name: r'ayaNo',
      type: IsarType.long,
    ),
    r'jozz': PropertySchema(
      id: 1,
      name: r'jozz',
      type: IsarType.long,
    ),
    r'page': PropertySchema(
      id: 2,
      name: r'page',
      type: IsarType.long,
    ),
    r'sora': PropertySchema(
      id: 3,
      name: r'sora',
      type: IsarType.long,
    ),
    r'soraNameAr': PropertySchema(
      id: 4,
      name: r'soraNameAr',
      type: IsarType.string,
    )
  },
  estimateSize: _quranMetadataEstimateSize,
  serialize: _quranMetadataSerialize,
  deserialize: _quranMetadataDeserialize,
  deserializeProp: _quranMetadataDeserializeProp,
  idName: r'id',
  indexes: {
    r'sora': IndexSchema(
      id: 9031632963855780408,
      name: r'sora',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sora',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'page': IndexSchema(
      id: -1004952015509011454,
      name: r'page',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'page',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _quranMetadataGetId,
  getLinks: _quranMetadataGetLinks,
  attach: _quranMetadataAttach,
  version: '3.1.0+1',
);

int _quranMetadataEstimateSize(
  QuranMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.soraNameAr;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _quranMetadataSerialize(
  QuranMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.ayaNo);
  writer.writeLong(offsets[1], object.jozz);
  writer.writeLong(offsets[2], object.page);
  writer.writeLong(offsets[3], object.sora);
  writer.writeString(offsets[4], object.soraNameAr);
}

QuranMetadata _quranMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuranMetadata();
  object.ayaNo = reader.readLong(offsets[0]);
  object.id = id;
  object.jozz = reader.readLong(offsets[1]);
  object.page = reader.readLong(offsets[2]);
  object.sora = reader.readLong(offsets[3]);
  object.soraNameAr = reader.readStringOrNull(offsets[4]);
  return object;
}

P _quranMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _quranMetadataGetId(QuranMetadata object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _quranMetadataGetLinks(QuranMetadata object) {
  return [];
}

void _quranMetadataAttach(
    IsarCollection<dynamic> col, Id id, QuranMetadata object) {
  object.id = id;
}

extension QuranMetadataQueryWhereSort
    on QueryBuilder<QuranMetadata, QuranMetadata, QWhere> {
  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhere> anySora() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sora'),
      );
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhere> anyPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'page'),
      );
    });
  }
}

extension QuranMetadataQueryWhere
    on QueryBuilder<QuranMetadata, QuranMetadata, QWhereClause> {
  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> soraEqualTo(
      int sora) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sora',
        value: [sora],
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> soraNotEqualTo(
      int sora) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sora',
              lower: [],
              upper: [sora],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sora',
              lower: [sora],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sora',
              lower: [sora],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sora',
              lower: [],
              upper: [sora],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> soraGreaterThan(
    int sora, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sora',
        lower: [sora],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> soraLessThan(
    int sora, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sora',
        lower: [],
        upper: [sora],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> soraBetween(
    int lowerSora,
    int upperSora, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sora',
        lower: [lowerSora],
        includeLower: includeLower,
        upper: [upperSora],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> pageEqualTo(
      int page) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'page',
        value: [page],
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> pageNotEqualTo(
      int page) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'page',
              lower: [],
              upper: [page],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'page',
              lower: [page],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'page',
              lower: [page],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'page',
              lower: [],
              upper: [page],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> pageGreaterThan(
    int page, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'page',
        lower: [page],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> pageLessThan(
    int page, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'page',
        lower: [],
        upper: [page],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterWhereClause> pageBetween(
    int lowerPage,
    int upperPage, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'page',
        lower: [lowerPage],
        includeLower: includeLower,
        upper: [upperPage],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension QuranMetadataQueryFilter
    on QueryBuilder<QuranMetadata, QuranMetadata, QFilterCondition> {
  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      ayaNoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ayaNo',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      ayaNoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ayaNo',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      ayaNoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ayaNo',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      ayaNoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ayaNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition> jozzEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jozz',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      jozzGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jozz',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      jozzLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jozz',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition> jozzBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jozz',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition> pageEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'page',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      pageGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'page',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      pageLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'page',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition> pageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'page',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition> soraEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sora',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sora',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sora',
        value: value,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition> soraBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sora',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'soraNameAr',
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'soraNameAr',
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soraNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'soraNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'soraNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'soraNameAr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'soraNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'soraNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'soraNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'soraNameAr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soraNameAr',
        value: '',
      ));
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterFilterCondition>
      soraNameArIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'soraNameAr',
        value: '',
      ));
    });
  }
}

extension QuranMetadataQueryObject
    on QueryBuilder<QuranMetadata, QuranMetadata, QFilterCondition> {}

extension QuranMetadataQueryLinks
    on QueryBuilder<QuranMetadata, QuranMetadata, QFilterCondition> {}

extension QuranMetadataQuerySortBy
    on QueryBuilder<QuranMetadata, QuranMetadata, QSortBy> {
  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> sortByAyaNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayaNo', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> sortByAyaNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayaNo', Sort.desc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> sortByJozz() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jozz', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> sortByJozzDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jozz', Sort.desc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> sortByPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'page', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> sortByPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'page', Sort.desc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> sortBySora() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sora', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> sortBySoraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sora', Sort.desc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> sortBySoraNameAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soraNameAr', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy>
      sortBySoraNameArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soraNameAr', Sort.desc);
    });
  }
}

extension QuranMetadataQuerySortThenBy
    on QueryBuilder<QuranMetadata, QuranMetadata, QSortThenBy> {
  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenByAyaNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayaNo', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenByAyaNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayaNo', Sort.desc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenByJozz() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jozz', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenByJozzDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jozz', Sort.desc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenByPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'page', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenByPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'page', Sort.desc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenBySora() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sora', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenBySoraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sora', Sort.desc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy> thenBySoraNameAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soraNameAr', Sort.asc);
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QAfterSortBy>
      thenBySoraNameArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soraNameAr', Sort.desc);
    });
  }
}

extension QuranMetadataQueryWhereDistinct
    on QueryBuilder<QuranMetadata, QuranMetadata, QDistinct> {
  QueryBuilder<QuranMetadata, QuranMetadata, QDistinct> distinctByAyaNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ayaNo');
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QDistinct> distinctByJozz() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jozz');
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QDistinct> distinctByPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'page');
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QDistinct> distinctBySora() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sora');
    });
  }

  QueryBuilder<QuranMetadata, QuranMetadata, QDistinct> distinctBySoraNameAr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'soraNameAr', caseSensitive: caseSensitive);
    });
  }
}

extension QuranMetadataQueryProperty
    on QueryBuilder<QuranMetadata, QuranMetadata, QQueryProperty> {
  QueryBuilder<QuranMetadata, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QuranMetadata, int, QQueryOperations> ayaNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ayaNo');
    });
  }

  QueryBuilder<QuranMetadata, int, QQueryOperations> jozzProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jozz');
    });
  }

  QueryBuilder<QuranMetadata, int, QQueryOperations> pageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'page');
    });
  }

  QueryBuilder<QuranMetadata, int, QQueryOperations> soraProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sora');
    });
  }

  QueryBuilder<QuranMetadata, String?, QQueryOperations> soraNameArProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'soraNameAr');
    });
  }
}
