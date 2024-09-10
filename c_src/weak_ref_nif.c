/* Copyright, 2024 Dominic Letz */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "erl_nif.h"

static ErlNifResourceType *weak_ref_type;
static ErlNifUInt64 weak_ref_counter;
static ErlNifMutex *weak_ref_mutex;


struct weak_ref {
    ErlNifPid owner;
    ErlNifUInt64 id;
};

static ERL_NIF_TERM
weak_ref_new(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifPid pid;
    if (argc != 1) return enif_make_badarg(env);
    if (!enif_get_local_pid(env, argv[0], &pid)) return enif_make_badarg(env);

    struct weak_ref *wr = (struct weak_ref*)enif_alloc_resource(weak_ref_type, sizeof(struct weak_ref));
    wr->owner = pid;
    enif_mutex_lock(weak_ref_mutex);
    wr->id = weak_ref_counter++;
    enif_mutex_unlock(weak_ref_mutex);
    ERL_NIF_TERM res = enif_make_resource(env, wr);
    ERL_NIF_TERM id = enif_make_uint64(env, wr->id);
    enif_release_resource(wr);
    return enif_make_tuple2(env, res, id);
}


static void
destruct_weak_ref_type(ErlNifEnv* env, void *arg)
{
    struct weak_ref *wr = (struct weak_ref *) arg;
    ERL_NIF_TERM id = enif_make_uint64(env, wr->id);
    ERL_NIF_TERM down = enif_make_atom(env, "DOWN");
    ERL_NIF_TERM ref = enif_make_atom(env, "weak_ref");
    enif_send(env, &wr->owner, NULL, enif_make_tuple3(env, down, id, ref));
}

static int
on_load(ErlNifEnv* env, void** priv, ERL_NIF_TERM info)
{
    (void)priv; // Suppress unused parameter warning
    (void)info; // Suppress unused parameter warning

    ErlNifResourceType *rt;

    rt = enif_open_resource_type(env, "weak_ref_nif", "weak_ref_type",
            destruct_weak_ref_type, ERL_NIF_RT_CREATE, NULL);
    if(!rt) return -1;


    weak_ref_mutex = enif_mutex_create("weak_ref_mutex");
    weak_ref_counter = 0;
    weak_ref_type = rt;
    return 0;
}

static int on_reload(ErlNifEnv* env, void** priv, ERL_NIF_TERM load_info)
{
    (void)env; // Suppress unused parameter warning
    (void)priv; // Suppress unused parameter warning
    (void)load_info; // Suppress unused parameter warning
    return 0;
}

static int on_upgrade(ErlNifEnv* env, void** priv, void** old_priv_data, ERL_NIF_TERM load_info)
{
    (void)env; // Suppress unused parameter warning
    (void)priv; // Suppress unused parameter warning
    (void)old_priv_data; // Suppress unused parameter warning
    (void)load_info; // Suppress unused parameter warning
    return 0;
}

static ErlNifFunc nif_funcs[] = {
    {"new", 1, weak_ref_new, 0},
};

ERL_NIF_INIT(Elixir.WeakRef, nif_funcs, on_load, on_reload, on_upgrade, NULL)

